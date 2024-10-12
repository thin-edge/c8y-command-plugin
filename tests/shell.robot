*** Settings ***
Resource    ./resources/common.robot
Library    Cumulocity
Library    DeviceLibrary    bootstrap_script=bootstrap.sh

Suite Setup    Test Setup
Suite Teardown    Collect Logs

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

*** Keywords ***

Test Setup
    ${DEVICE_SN}=    Setup
    Set Suite Variable    $DEVICE_SN
    Device Should Exist    ${DEVICE_SN}

Collect Logs
    Get Workflow Logs
    Get Service Logs

Get Workflow Logs
    DeviceLibrary.Execute Command    head -n-0 /var/log/tedge/agent/*

Get Service Logs
    DeviceLibrary.Execute Command    journalctl --no-pager
