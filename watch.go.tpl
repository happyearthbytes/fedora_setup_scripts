{{- range .items -}}
{{$phase := ""}}{{$kind := .kind}}
+ {{printf "%-12s" .metadata.namespace}}{{"\t" -}}
{{- with .metadata.ownerReferences}}{{range .}}{{.kind}}/{{.name}} -> {{end}}{{end -}}{{.kind}}/{{.metadata.name}}{{$phase := .status.phase}}{{with $phase}} ({{$phase}}){{end -}}
{{- if eq $phase "Succeeded" -}}
{{else}}
{{- with .status.containerStatuses }}{{range .}}{{"\n\t"}}{{.name}}[{{.restartCount}}]
{{- range $k, $v := .state}}
{{- with $x := $v.reason}} {{$x}}->{{end -}}
{{$k}}
{{- with $x := $v.message}}
{{"\t"}}Message: "{{$x}}"
{{- end}}{{end}}{{end}}{{end -}}
{{/*- with .spec.serviceAccount}}{{"\n\t"}}ServiceAccount: {{.}}{{end -*/}}
{{- with .status.conditions}}{{range .}}{{if eq .status "False"}}{{"\n\t"}}{{.type}}={{.status}} ({{.reason}}) "{{.message}}"{{end}}{{end}}{{end -}}
{{- end -}}
{{- end}}


{{/*

{{- with .status.conditions}}{{range .}}{{if eq .status "False"}}{{"\n\t"}}{{.type}}={{.status}}({{.reason}}}){{end}}{{end}}{{end -}}
{{- with $x := .status.conditions}}{{range $x}} {{.type}}={{.reason}} {{end}}{{end -}}


{{$podname := ""}}
{{- range $index, $element := .items -}}
    {{- range $container, $status := $element.status.containerStatuses -}}
        {{ if (eq $container 0 )}}
            {{- $podname = printf "%s %s" $element.metadata.name "\n|-->" -}}
        {{else}}
            {{- $podname = "|-->" -}}
        {{end}}
        {{- if not .ready -}}
            {{ $podname }} {{ $status.name }} {{ "not-ready" }}{{"\n"}}
        {{- else -}}
            {{$podname}} {{ $status.name }} {{"ready"}}{{"\n"}}
        {{- end -}}
    {{- end -}}
{{- end -}}
*/}}