{{/*
Environment variables
*/}}
{{- define "app.env" -}}
{{- $env := list -}}
{{- $defaultEnv := list
  (dict "name" "SERVICE_NAME" "value" (include "app.name" .))
  (dict "name" "INSTANCE_NAME" "valueFrom" (dict "fieldRef" (dict "fieldPath" "metadata.name")))
-}}
{{- $env = concat $env $defaultEnv -}}
{{- if .Values.rabbitmq.enabled }}
{{- $rabbitmqEnv := list
  (dict "name" "AMQP_PASSWORD" "valueFrom" (dict "secretKeyRef" (dict "name" .Values.rabbitmq.secret "key" .Values.rabbitmq.passwordKey)))
  (dict "name" "AMQP_URL" "value" (printf "amqp://%s:$(AMQP_PASSWORD)@%s:%v" .Values.rabbitmq.user .Values.rabbitmq.host .Values.rabbitmq.port))
-}}
{{- $env = concat $env $rabbitmqEnv -}}
{{- end }}
{{- if .Values.postgres.enabled }}
{{- $pgSecretName := printf "%s-pg-app" (include "app.name" .) -}}
{{- $pgPrefix := .Values.postgres.envPrefix -}}
{{- $postgresEnv := list
  (dict "name" "DATABASE_URL" "valueFrom" (dict "secretKeyRef" (dict "name" $pgSecretName "key" "uri")))
  (dict "name" (printf "%s_USER" $pgPrefix) "valueFrom" (dict "secretKeyRef" (dict "name" $pgSecretName "key" "user")))
  (dict "name" (printf "%s_PASSWORD" $pgPrefix) "valueFrom" (dict "secretKeyRef" (dict "name" $pgSecretName "key" "password")))
  (dict "name" (printf "%s_HOST" $pgPrefix) "valueFrom" (dict "secretKeyRef" (dict "name" $pgSecretName "key" "host")))
  (dict "name" (printf "%s_PORT" $pgPrefix) "valueFrom" (dict "secretKeyRef" (dict "name" $pgSecretName "key" "port")))
  (dict "name" (printf "%s_DB" $pgPrefix) "valueFrom" (dict "secretKeyRef" (dict "name" $pgSecretName "key" "dbname")))
-}}
{{- $env = concat $env $postgresEnv -}}
{{- end }}
{{- if .Values.env }}
{{- $env = concat $env .Values.env -}}
{{- end }}
{{- if $env }}
{{- toYaml $env }}
{{- end }}
{{- end }}
