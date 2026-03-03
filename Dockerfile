FROM python:3.13-slim

USER app

WORKDIR /app

COPY ./main.py /app/main.py

CMD [ "python3", "main.py" ]