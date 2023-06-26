package workflows

import "json.schemastore.org/github"

_#workflow: {
	filename: string
	workflow: github.#Workflow
	...
}

_#checkoutCode: {
	name: "Checkout code"
	uses: "actions/checkout@v3.5.3"
	with: {
		token: "${{ secrets.PAT }}"
	}
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
					uses: "actions/setup-python@v4.6.1"
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
						curl -L https://github.com/kharf/monoreleaser/releases/download/v0.0.9/monoreleaser-linux-amd64 --output monoreleaser
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
			workflow_dispatch: null
			schedule: [{
				cron: "0 5 * * 1-5"
			},
			]
		}

		permissions: "read-all"

		jobs: renovate: {
			"runs-on": "ubuntu-latest"
			steps: [
				_#checkoutCode,
				{
					name: "Renovate"
					uses: "renovatebot/github-action@v38.1.8"
					env: {
						LOG_LEVEL:             "debug"
						RENOVATE_REPOSITORIES: "${{ github.repository }}"
					}
					with: {
						configurationFile: "renovate.json"
						token:             "${{ secrets.PAT }}"
					}
				},
			]
		}
	}
}

genWorkflow: _#workflow & {
	filename: "gen.yaml"
	workflow: github.#Workflow & {
		name: "generate"
		on: {
			push: {
				branches: [
					"main",
				]
				"tags-ignore": [
					"*",
				]
				paths: [
					".github/workflows/**",
					"catalog/**",
				]
			}
		}

		permissions: "read-all"

		jobs: generate: {
			"runs-on": "ubuntu-latest"
			steps: [
				_#checkoutCode,
				{
					name: "Setup CUE"
					uses: "cue-lang/setup-cue@v0.0.1"
					with: {
						version: "v0.5.0"
					}
				},
				{
					name:                "Generate"
					"working-directory": ".github/workflows"
					run: """
						cue cmd genworkflows
						cue cmd genyamlworkflows
						"""
				},
				{
					name: "Create PR"
					uses: "peter-evans/create-pull-request@v5.0.2"
					with: {
						token:            "${{ secrets.PAT }}"
						"commit-message": "chore: update yamls generated from cue definitions"
						"title":          "chore: update yamls generated from cue definitions"
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
			workflow_dispatch: {
				branches: [
					"main",
				]
			}
			push: {
				branches: [
					"main",
				]
				"tags-ignore": [
					"*",
				]
				paths: [
					"catalog/\(tool)/**",
				]
			}
			pull_request: {
				branches: [
					"*",
				]
				"tags-ignore": [
					"*",
				]
				paths: [
					"catalog/\(tool)/**",
				]
			}
		}

		env: {
			GITHUB_USER:    "kharf"
			GITHUB_TOKEN:   "${{ secrets.PAT }}"
			REPOSITORY_URL: "https://github.com/kharf/flux-k8s-stack"
			BRANCH:         "${{ github.head_ref || github.ref_name }}"
			CLUSTER_NAME:   tool
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
