FROM python:3.9-slim 

WORKDIR /app

COPY requirements.txt .
COPY templates/ templates
COPY tests/ tests
COPY app.py .

RUN pip install -r requirements.txt

EXPOSE 5000

CMD ["python", "app.py"]
