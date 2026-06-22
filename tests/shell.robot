*** Settings ***
Resource    ./resources/common.robot

Test Setup       Setup Device
Test Teardown    Teardown Device

*** Test Cases ***

Capability message is visible
    ${output}=    DeviceLibrary.Execute Command    timeout 2 tedge mqtt sub te/device/main///cmd/shell_execute    ignore_exit_code=${True}    strip=${True}
    Should Be Equal    ${output}    [te/device/main///cmd/shell_execute] {}

Execute command
    ${operation}=    Cumulocity.Create Operation
    ...    description=echo helloworld
    ...    fragments={"c8y_Command":{"text":"echo helloworld"}}

    Operation Should Be SUCCESSFUL    ${operation}
    Should Be Equal    ${operation.to_json()["c8y_Command"]["result"]}    helloworld\n

Execute command that fails
    ${operation}=    Cumulocity.Create Operation
    ...    description=example
    ...    fragments={"c8y_Command":{"text":"echo foo; exit 1"}}

    Operation Should Be FAILED    ${operation}

Execute command works even if the /tmp folder is full
    Execute Command    cmd=dd if=/dev/zero of=/tmp/example bs=$((64)) count=$((10000*1024)) || true
    ${operation}=    Cumulocity.Create Operation
    ...    description=execute command and ignore output
    ...    fragments={"c8y_Command":{"text":"echo helloworld > /dev/null"}}

    Operation Should Be SUCCESSFUL    ${operation}
