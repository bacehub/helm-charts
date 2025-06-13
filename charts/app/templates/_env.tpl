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
  (dict "name" "AMQP_PASSWORD" "valueFrom" (dict "secretKeyRef" (dict "name" .Values.rabbitmq.secretName "key" .Values.rabbitmq.passwordKey)))
  (dict "name" "AMQP_URL" "value" (printf "amqp://%s:$(AMQP_PASSWORD)@%s:%v" .Values.rabbitmq.user .Values.rabbitmq.host .Values.rabbitmq.port))
-}}
{{- $env = concat $env $rabbitmqEnv -}}
{{- end }}
{{- if .Values.env }}
{{- $env = concat $env .Values.env -}}
{{- end }}
{{- if $env }}
{{- toYaml $env }}
{{- end }}
{{- end }}
