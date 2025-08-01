{{/*
Environment variables - outputs YAML format directly
*/}}
{{- define "app.env" -}}
{{- /* Default environment variables */ -}}
- name: SERVICE_NAME
  value: {{ include "app.fullname" . | quote }}
- name: INSTANCE_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
{{- /* RabbitMQ environment variables */ -}}
{{- if .Values.rabbitmq.enabled }}
- name: AMQP_PASSWORD
  {{- if .Values.rabbitmq.password }}
  value: {{ .Values.rabbitmq.password | quote }}
  {{- else }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.rabbitmq.secret.name }}
      key: {{ .Values.rabbitmq.secret.passwordKey }}
  {{- end }}
- name: AMQP_URL
  value: {{ printf "amqp://%s:$(AMQP_PASSWORD)@%s:%v" .Values.rabbitmq.user .Values.rabbitmq.host .Values.rabbitmq.port | quote }}
{{- end }}
{{- /* PostgreSQL environment variables */ -}}
{{- if .Values.postgres.enabled }}
{{- $pgSecretName := printf "%s-pg-app" (include "app.fullname" .) -}}
{{- $pgPrefix := .Values.postgres.envPrefix }}
- name: DATABASE_URL
  valueFrom:
    secretKeyRef:
      name: {{ $pgSecretName }}
      key: uri
- name: {{ printf "%s_USER" $pgPrefix }}
  valueFrom:
    secretKeyRef:
      name: {{ $pgSecretName }}
      key: user
- name: {{ printf "%s_PASSWORD" $pgPrefix }}
  valueFrom:
    secretKeyRef:
      name: {{ $pgSecretName }}
      key: password
- name: {{ printf "%s_HOST" $pgPrefix }}
  valueFrom:
    secretKeyRef:
      name: {{ $pgSecretName }}
      key: host
- name: {{ printf "%s_PORT" $pgPrefix }}
  valueFrom:
    secretKeyRef:
      name: {{ $pgSecretName }}
      key: port
- name: {{ printf "%s_DB" $pgPrefix }}
  valueFrom:
    secretKeyRef:
      name: {{ $pgSecretName }}
      key: dbname
{{- end }}
{{- /* User-defined environment variables */ -}}
{{- if .Values.env }}
{{ toYaml .Values.env }}
{{- end }}
{{- /* User-defined environment overlay */ -}}
{{- if .Values.envOverlay }}
{{ toYaml .Values.envOverlay }}
{{- end }}
{{- end }}
