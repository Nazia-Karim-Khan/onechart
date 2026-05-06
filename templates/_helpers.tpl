{{/*
Expand the name of the chart.
*/}}
{{- define "springboot-app-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "springboot-app-chart.fullname" -}}
{{- if .Values.fullNameOverride }}
{{- .Values.fullNameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "springboot-app-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "springboot-app-chart.labels" -}}
helm.sh/chart: {{ include "springboot-app-chart.chart" . }}
{{ include "springboot-app-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "springboot-app-chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "springboot-app-chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "springboot-app-chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "springboot-app-chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Vault role: explicit override or <team>-<namespace>.
*/}}
{{- define "onechart.vaultRole" -}}
{{- $vault := .Values.secrets.vault -}}
{{- $vault.role | default (printf "%s-%s-db" $vault.team .Release.Namespace) -}}
{{- end -}}

{{/*
Vault secret path: explicit override or <team>-<namespace>/creds/<team>.
*/}}
{{- define "onechart.vaultSecretPath" -}}
{{- $vault := .Values.secrets.vault -}}
{{- $vault.secretPath | default (printf "%s-%s/creds/%s" $vault.team .Release.Namespace $vault.team) -}}
{{- end -}}

{{/*
Body of the vault-injected database.properties template. Emits the literal
{{ .Data.<field> }} expressions for the vault agent to render at pod start.
*/}}
{{- define "onechart.vaultDatabaseTemplate" -}}
{{- $secretPath := include "onechart.vaultSecretPath" . -}}
{{ printf "{{- with secret %q }}" $secretPath }}
{{- range $env := .Values.secrets.vault.keys }}
{{- $field := $env | splitList "_" | last | lower }}
{{ $env }}={{ printf "{{ .Data.%s }}" $field }}
{{- end }}
{{ "{{- end }}" }}
{{- end -}}
