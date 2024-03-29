{{- define "library.communityDeployment" -}}
{{- $env := .Values.env | default dict -}}
{{- if .Values.communityDeployment}}
{{- $root := . -}}
{{- range $index, $element := .Values.communityDeployment}}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{$element.name}}
  namespace: {{ $root.Values.namespace }}
  labels:
    app: {{$element.name}}

spec:
  replicas: 1
  revisionHistoryLimit: 1
  selector:
    matchLabels:
      app: {{$element.name}}
  template:
    metadata:
      labels:
        app: {{$element.name}}
      annotations:
        rollme: {{ randAlphaNum 5 | quote }}
    spec:
      {{- if $element.volumes }}
      volumes:
      {{- range $index2, $vols := $element.volumes}}
      {{- if eq $vols.type "pvc" }}
      - name: {{$vols.name}}
        persistentVolumeClaim:
          claimName: {{$vols.name }}
      {{- else if eq $vols.type "config" }}
      - name: {{$vols.name}}
        configMap:
          name: {{$vols.name }}
      {{- else if eq $vols.type "hostpath" }}
      - name: {{$vols.name}}
        hostPath:
          path: {{$vols.path }}
      {{- end }}
      {{- end }}
      {{- end }}
      containers:
      - name: {{$element.name}}
        image: "{{$element.image}}"
        imagePullPolicy: Always
        ports:
        {{- range $index2, $ports := $element.ports}}
        - containerPort: {{$ports.port}}
        {{- end }}
        {{- if $element.resources}}
        resources:
          limits:
            memory: {{$element.resources.memory}}
            cpu: {{$element.resources.cpu }}
        {{- end }}
        {{- if $element.volumes}}
        volumeMounts:
        {{- range $index2, $vols := $element.volumes}}
        {{- if eq $vols.type "config" }}
        - name: {{$vols.name}}
          mountPath: {{$vols.path }}
        {{- else if eq $vols.type "hostpath" }}
        - name: {{$vols.name}}
          mountPath: {{$vols.path }}
        {{- else if eq $vols.type "pvc" }}
        - name: {{$vols.name}}
          mountPath: {{$vols.path }}
        {{- end }}
        {{- end }}
        {{- end }}
        {{- if $element.env}}
        env:
        {{- range $index2, $vars := $element.env}}
          - name: {{ $vars.name }}
            value: {{ $vars.value }}
        {{- end }}
        {{- end }}
      restartPolicy: Always
{{- end }}
{{- end }}
{{- end }}