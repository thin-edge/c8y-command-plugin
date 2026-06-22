set positional-arguments
set dotenv-load
set export

build *ARGS:
    ./ci/build.sh {{ARGS}} -- -f nfpm.tedge-command-plugin.yaml

publish *ARGS:
    ./ci/publish.sh {{ARGS}}

# Install python virtual environment
venv:
  [ -d .venv ] || python3 -m venv .venv
  ./.venv/bin/pip3 install -r tests/requirements.txt

# Run tests
test *args='':
  ./.venv/bin/python3 -m robot.run --outputdir output {{args}} tests
