from fastapi.responses import JSONResponse
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine, text
from fastapi import FastAPI, Depends
from fastapi import status
from pydantic import BaseModel
import datetime as dt
import pandas as pd

app = FastAPI()

# Configuração da conexão com o banco de dados MySQL
SQLALCHEMY_DATABASE_URL = "mysql+pymysql://root:senhadobancodedados1@localhost:3306/IoT"

class Database:
    def __init__(self):
        self.engine = create_engine(SQLALCHEMY_DATABASE_URL)
        self.SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=self.engine)

    def get_db(self):
        db = self.SessionLocal()
        try:
            yield db
        finally:
            db.close()

db_instance = Database()

def finaliza_aula(db, id_aula,id_prof):
    table = db.execute(text(f"SELECT * FROM presenca_{id_aula}"))
    table = table.fetchall()
    df = pd.DataFrame(table)
    df['tempo_presente'] = df['saida'] - df['entrada']
    tempo_aula = df[df['usuario_id'] == id_prof]['tempo_presente'].iloc[0]
    df['pc'] = (df['tempo_presente'] / tempo_aula) * 100
    df['faltas'] = df['pc'].apply(lambda x: faltas(x))
    
    for _,row in df.iterrows():
        if row['usuario_id']==id_prof:
            continue

        db.execute(text("""
                   UPDATE alunos_materias 
                   SET faltas=faltas+:faltas 
                   WHERE aluno_id=:id_user 
                   AND materia_id=(SELECT materia_id FROM aulas WHERE id=:id_aula)"""),
                   {"faltas":row['faltas'],"id_user":row['usuario_id'],"id_aula":id_aula})
        db.commit()
    db.execute(text(f"DROP TABLE presenca_{id_aula}"))

    return JSONResponse(status_code=status.HTTP_200_OK, content={"status": "Aula Finalizada com Sucesso, e Alunos com as faltas computadas!"})

def faltas(porcentagem):
    if(porcentagem>0.75*100):
        return 0
    elif (porcentagem>0.75*66):
        return 1
    elif (porcentagem>0.75*33):
        return 2
    else:
        return 3

def check_entrada(db,id_aula, id_user):
    entrada = db.execute(text(f"SELECT entrada FROM presenca_{id_aula} WHERE usuario_id=:id_user"), {"id_user": id_user})
    entrada = entrada.fetchone()
    if entrada is None:
        return False
    else:
        return True

def insert_entrada(db, id_aula, id_user, hora):
    db.execute(text(f"""INSERT INTO presenca_{id_aula} (usuario_id, entrada) VALUES (:id_user, :hora)"""), {"id_user": id_user, "hora": hora})
    db.commit()
    return JSONResponse(status_code=status.HTTP_200_OK, content={"status": "Usuário Entrou com sucesso!"})

class UserIdRequest(BaseModel):
    id_user: str
    hora: str

@app.post("/db_conn")
def db_conn(user_id: UserIdRequest, db=Depends(db_instance.get_db)):
    try:
        data_hora = dt.datetime.strptime(user_id.hora, "%Y-%m-%d %H:%M:%S")
        dia = data_hora.weekday()
        hora = data_hora.time()

        info_user = db.execute(text("SELECT * FROM usuarios WHERE rfid=:id_user"), {"id_user": user_id.id_user})
        info_user = info_user.fetchone()
        tipo = info_user[3]
        id_user = info_user[0]

        # Ver qual aula o usuário está participando
        if tipo == 1:
            # Lógica para professor
            aulas = db.execute(text("""SELECT aulas.* FROM aulas
                                JOIN materias ON aulas.materia_id=materias.id
                                WHERE professor_id=:id_user
                                AND dias_semana=:dia
                                ORDER BY ABS(TIMEDIFF(hora_inicio, :hora))
                                LIMIT 1;"""), {"id_user": id_user, "hora": hora, "dia": dia})
        elif tipo == 2:
            # Lógica para aluno
            aulas = db.execute(text("""SELECT aulas.* FROM aulas
                        JOIN materias ON aulas.materia_id = materias.id
                        JOIN alunos_materias am ON materias.id = am.materia_id
                        WHERE am.aluno_id=:id_user
                        AND dias_semana=:dia
                        ORDER BY ABS(TIMEDIFF(hora_inicio, :hora))
                        LIMIT 1;"""), {"id_user": id_user, "hora": hora, "dia": dia})


        aulas = aulas.fetchone()
        try:
            id_aula = aulas[0]
        except TypeError:
            return JSONResponse(status_code=status.HTTP_404_NOT_FOUND, content={"status": "Nenhuma aula encontrada para o usuário neste horário."})
        result = db.execute(text(f"SHOW TABLES LIKE 'presenca_{id_aula}'"))
        
        if not result.fetchone():
            # A tabela existe
            db.execute(text(f"""CREATE TABLE presenca_{id_aula} (
            id INT AUTO_INCREMENT PRIMARY KEY,
            usuario_id INT REFERENCES usuarios(id),
            entrada TIME NOT NULL,
            saida TIME
            );"""))
            return insert_entrada(db, id_aula, id_user, hora)
        
        if check_entrada(db, id_aula, id_user):
            if tipo == 1:
                # Lógica para professor
                # Se já existe entrada, atualiza a saída
                db.execute(text(f"UPDATE presenca_{id_aula} SET saida=:hora WHERE usuario_id=:id_user"), {"id_user": id_user, "hora": hora})
                db.commit()
                return finaliza_aula(db,id_aula,id_user)
                
            elif tipo == 2:
                # Lógica para aluno
                db.execute(text(f"UPDATE presenca_{id_aula} SET saida=:hora WHERE usuario_id=:id_user"), {"id_user": id_user, "hora": hora})
                db.commit()
                return JSONResponse(status_code=status.HTTP_200_OK, content={"status": "Usuário Saiu com sucesso!"})
            else:
                return JSONResponse(status_code=status.HTTP_400_BAD_REQUEST, content={"status": "Tipo de usuário inválido!"})
        else:
            if tipo == 1:
                db.execute(text(f"UPDATE presenca_{id_aula} SET entrada=:hora WHERE usuario_id=:id_user"), {"id_user": id_user, "hora": hora})
                db.commit()
            db.execute(text(f"UPDATE presenca_{id_aula} SET entrada=:hora WHERE usuario_id>0;"), {"hora": hora})
            db.commit()
            return insert_entrada(db, id_aula, id_user, hora)

    except Exception as e:
        return JSONResponse(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, content={"status": "Erro ao processar a requisição", "error": str(e)})
