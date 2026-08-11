FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

COPY  app/requirment.txt .

RUN pip install --no-cache-dir -r requirment.txt

COPY app/app.py .

EXPOSE 8000

CMD ["python", "app.py"]
