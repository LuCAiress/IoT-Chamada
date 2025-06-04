import datetime as dt

data_hora = dt.datetime.strptime("2025-06-04 19:10:00", "%Y-%m-%d %H:%M:%S")
dia = data_hora.weekday()
print(dia)