FROM python:3.11-slim

WORKDIR /app

COPY pyproject.toml README.md MANIFEST.in ./
COPY src ./src

RUN pip install --no-cache-dir -e .

EXPOSE 5000

ENV FLASK_ENV=production
ENV HOST=0.0.0.0
ENV PORT=5000

CMD ["mddocx-webui"]
