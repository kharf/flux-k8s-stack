// AUTOGENERATED - DO NOT EDIT

package workflows

_#certmanagertest: _#test & {
	tool: "cert-manager"
}

_#emissaryingresstest: _#test & {
	tool: "emissary-ingress"
}

_#ingressnginxtest: _#test & {
	tool: "ingress-nginx"
}

_#istiostacktest: _#test & {
	tool: "istio-stack"
}

_#kedatest: _#test & {
	tool: "keda"
}

_#kubeprometheusstacktest: _#test & {
	tool: "kube-prometheus-stack"
}

_#kyvernotest: _#test & {
	tool: "kyverno"
}

_#linkerd2test: _#test & {
	tool: "linkerd2"
}

_#lokistacktest: _#test & {
	tool: "loki-stack"
}

_#prometheusstackdriverexportertest: _#test & {
	tool: "prometheus-stackdriver-exporter"
}


testWorkflows: [..._#test] & [
	_#certmanagertest,
	_#emissaryingresstest,
	_#ingressnginxtest,
	_#istiostacktest,
	_#kedatest,
	_#kubeprometheusstacktest,
	_#kyvernotest,
	_#linkerd2test,
	_#lokistacktest,
	_#prometheusstackdriverexportertest,
	
]