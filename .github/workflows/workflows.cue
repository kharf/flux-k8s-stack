package workflows

import "json.schemastore.org/github"

_#workflow: {
	filename: string
	workflow: github.#Workflow
	...
}

_#checkoutCode: {
	name: "Checkout code"
	uses: "actions/checkout@v3"
}

lintWorkflow: _#workflow & {
	filename: "lint.yaml"
	workflow: github.#Workflow & {
		name: "lint"
		on: {
			pull_request: {
				branches: [
					"*",
				]
				"tags-ignore": [
					"*",
				]
			}
		}

		permissions: "read-all"

		jobs: lint: {
			"runs-on": "ubuntu-latest"
			steps: [
				_#checkoutCode,
				{
					name: "Setup python"
					uses: "actions/setup-python@v4"
				},
				{
					name: "Lint"
					run:  "./scripts/checkov.sh"
				},
			]
		}
	}
}

releaseWorkflow: _#workflow & {
	filename: "release.yaml"
	workflow: github.#Workflow & {
		name: "release"
		on: {
			workflow_dispatch: {
				branches: [
					"main",
				]
				inputs: version: {
					description: "version to be released"
					required:    true
				}
			}
		}

		permissions: "read-all"

		jobs: release: {
			"runs-on": "ubuntu-latest"
			steps: [
				{
					_#checkoutCode
					with: {
						ref:           "${{ github.event.inputs.branch }}"
						"fetch-depth": "0"
					}
				},
				{
					name: "Release"
					env: MR_GITHUB_TOKEN: "${{ secrets.PAT }}"
					run: """
						curl -L https://github.com/kharf/monoreleaser/releases/download/v0.0.6/monoreleaser-linux-amd64 --output monoreleaser
						chmod +x monoreleaser
						./monoreleaser release . ${{ inputs.version }}
						"""
				},
			]
		}
	}
}

renovateWorkflow: _#workflow & {
	filename: "renovate.yaml"
	workflow: github.#Workflow & {
		name: "renovate"
		on: {
			workflow_dispatch: {
				schedule: cron: "0 5 * * 1-5"
			}
		}

		permissions: "read-all"

		jobs: renovate: {
			"runs-on": "ubuntu-latest"
			steps: [
				_#checkoutCode,
				{
					name: "Renovate"
					uses: "renovatebot/github-action@v37.0.0"
					env: RENOVATE_REPOSITORIES: "${{ github.repository }}"
					with: {
						configurationFile: "renovate.json"
						token:             "${{ secrets.PAT }}"
					}
				},
			]
		}
	}
}

_#test: _#workflow & {
	tool:     string
	filename: "\(tool)-test.yaml"
	workflow: github.#Workflow & {
		name: "\(tool)-test"
		on: {
			workflow_dispatch: null
			pull_request: {
				branches: [
					"*",
				]
				"tags-ignore": [
					"*",
				]
				paths: [
					"./catalog/\(tool)/**",
				]
			}
		}

		env: {
			GITHUB_USER:    "kharf"
			GITHUB_TOKEN:   "${{ secrets.PAT }}"
			REPOSITORY_URL: "https://github.com/kharf/flux-k8s-stack"
			BRANCH:         "${{ github.event.pull_request.head.ref }}"
			KS_PATH:        "./catalog/\(tool)/test"
		}

		permissions: "read-all"

		jobs: test: {
			"runs-on": "ubuntu-latest"
			steps: [
				_#checkoutCode,
				{
					name: "Test"
					run:  "./scripts/local-setup.sh"
				},
			]
		}
	}
}