FROM python:3.9-slim as builder

WORKDIR /app

COPY app.py .
COPY requirements.txt .
COPY templates/ templates

RUN pip install -r requirements.txt

EXPOSE 5000

CMD ["python", "app.py"]
