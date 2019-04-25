FROM python:3.6

ARG DDT_ENV
ARG DDT_SRC_DIR
ARG POETRY_VERSION

ENV PYTHONUNBUFFERED=1

RUN pip install "poetry==$POETRY_VERSION"

RUN mkdir -p "${DDT_SRC_DIR}"
COPY pyproject.toml poetry.lock "${DDT_SRC_DIR}"/
WORKDIR "${DDT_SRC_DIR}"/

RUN poetry config settings.virtualenvs.create false \
  && poetry install $(test "${DDT_ENV}" = "production" && echo "--no-dev") --no-interaction --no-ansi
