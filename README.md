# c8y-command-plugin

thin-edge.io Cumulocity IoT shell plugin to process the `c8y_Command` operation.

## Plugin summary

### What will be deployed to the device?

* Cumulocity IoT command handler (binary) that allows users to execute a command in a shell

**Technical summary**

The following details the technical aspects of the plugin to get an idea what systems it supports.

|||
|--|--|
|**Languages**|`shell` (posix compatible)|
|**CPU Architectures**|`all/noarch`. Not CPU specific|
|**Supported init systems**|`N/A`|
|**Required Dependencies**|-|
|**Optional Dependencies (feature specific)**|-|

### How to do I get it?

The following linux package formats are provided on the releases page and also in the [tedge-community](https://cloudsmith.io/~thinedge/repos/community/packages/) repository:

|Operating System|Repository link|
|--|--|
|Debian/Raspian (deb)|[![Latest version of 'c8y-command-plugin' @ Cloudsmith](https://api-prd.cloudsmith.io/v1/badges/version/thinedge/community/deb/c8y-command-plugin/latest/a=all;d=any-distro%252Fany-version;t=binary/?render=true&show_latest=true)](https://cloudsmith.io/~thinedge/repos/community/packages/detail/deb/c8y-command-plugin/latest/a=all;d=any-distro%252Fany-version;t=binary/)|
|Alpine Linux (apk)|[![Latest version of 'c8y-command-plugin' @ Cloudsmith](https://api-prd.cloudsmith.io/v1/badges/version/thinedge/community/alpine/c8y-command-plugin/latest/a=noarch;d=alpine%252Fany-version/?render=true&show_latest=true)](https://cloudsmith.io/~thinedge/repos/community/packages/detail/alpine/c8y-command-plugin/latest/a=noarch;d=alpine%252Fany-version/)|
|RHEL/CentOS/Fedora (rpm)|[![Latest version of 'c8y-command-plugin' @ Cloudsmith](https://api-prd.cloudsmith.io/v1/badges/version/thinedge/community/rpm/c8y-command-plugin/latest/a=noarch;d=any-distro%252Fany-version;t=binary/?render=true&show_latest=true)](https://cloudsmith.io/~thinedge/repos/community/packages/detail/rpm/c8y-command-plugin/latest/a=noarch;d=any-distro%252Fany-version;t=binary/)|

#### Configuration

The Cumulocity IoT shell plugin can be configured with the following properties.

|Property|Value|Description|
|--|--|--|
|`SHELL_BIN`|`string`|Default shell to be used to execute the received command. If left blank, then the shell will be auto-detected. If a non-empty value is used. If the shell does not exist, then an error will be raised. The shell will be used using `<shell> -c "<COMMAND>"`.|
|`SHELL_OPTIONS`|Whitespace separated list|List of shells to check if they exist. The plugin will use the first detected shell|

The configuration is managed from the following file, and an example of the contents are shown below.

**File**

```sh
/etc/c8y-command-plugin/env
```

**Contents**

```sh
SHELL_BIN=""
SHELL_OPTIONS="bash zsh ash dash sh /my/custom/shell/interpreter"
```
