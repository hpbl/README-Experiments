# Microsoft.Build (MSBuild)

The Microsoft Build Engine is a platform for building applications. This engine, which is also known as MSBuild, provides an XML schema for a project file that controls how the build platform processes and builds software. Visual Studio uses MSBuild, but MSBuild *does not* depend on Visual Studio. By invoking msbuild.exe on your project or solution file, you can orchestrate and build products in environments where Visual Studio isn't installed.

For more information on MSBuild, see the [MSBuild documentation](https://docs.microsoft.com/visualstudio/msbuild/msbuild) on docs.microsoft.com.

### Build Status

The current development branch is `master`. Changes in `master` will go into a future update of MSBuild, which will release with Visual Studio 16.3 and .NET Core SDK 3.0.100.

[![Build Status](https://dev.azure.com/dnceng/public/_apis/build/status/Microsoft/msbuild/msbuild-pr?branchName=master)](https://dev.azure.com/dnceng/public/_build/latest?definitionId=86&branchName=master)

We have forked for MSBuild 16.2 in the branch [`vs16.2`](https://github.com/Microsoft/msbuild/tree/vs16.2). Changes to that branch need special approval.

[![Build Status](https://dev.azure.com/dnceng/public/_apis/build/status/Microsoft/msbuild/msbuild-pr?branchName=vs16.2)](https://dev.azure.com/dnceng/public/_build/latest?definitionId=86&branchName=vs16.2)

MSBuild 16.0 builds from the branch [`vs16.0`](https://github.com/Microsoft/msbuild/tree/vs16.0). Only high-priority bugfixes will be considered for servicing 16.0.

[![Build Status](https://dev.azure.com/dnceng/public/_apis/build/status/Microsoft/msbuild/msbuild-pr?branchName=vs16.0)](https://dev.azure.com/dnceng/public/_build/latest?definitionId=86&branchName=vs16.0)

MSBuild 15.9 builds from the branch [`vs15.9`](https://github.com/Microsoft/msbuild/tree/vs15.9). Only very-high-priority bugfixes will be considered for servicing 15.9.

| Runtime\OS | Windows | Ubuntu 16.04 |Mac OS X|
|:------|:------:|:------:|:------:|
| **Full Framework** |[![Build Status](https://ci2.dot.net/buildStatus/icon?job=Microsoft_msbuild/vs15.9/innerloop_Windows_NT_Full)](https://ci2.dot.net/job/Microsoft_msbuild/job/vs15.9/job/innerloop_Windows_NT_Full)| N/A | N/A | N/A |
|**.NET Core**|[![Build Status](https://ci2.dot.net/buildStatus/icon?job=Microsoft_msbuild/vs15.9/innerloop_Windows_NT_CoreCLR)](https://ci2.dot.net/job/Microsoft_msbuild/job/vs15.9/job/innerloop_Windows_NT_CoreCLR)|[![Build Status](https://ci2.dot.net/buildStatus/icon?job=Microsoft_msbuild/vs15.9/innerloop_Ubuntu16.04_CoreCLR)](https://ci2.dot.net/job/Microsoft_msbuild/job/vs15.9/job/innerloop_Ubuntu16.04_CoreCLR)|[![Build Status](https://ci2.dot.net/buildStatus/icon?job=Microsoft_msbuild/vs15.9/innerloop_OSX10.13_CoreCLR)](https://ci2.dot.net/job/Microsoft_msbuild/job/vs15.9/job/innerloop_OSX10.13_CoreCLR)|

### Source code

* Clone the sources: `git clone https://github.com/Microsoft/msbuild.git`

## Building

### Building MSBuild with Visual Studio 2019

For the full supported experience, you will need to have Visual Studio 2019 or higher.

To get started on **Visual Studio 2019**:

1. [Install Visual Studio 2019](https://www.visualstudio.com/vs/).  Select the following Workloads:
  - _.NET desktop development_
  - _.NET Core cross-platform development_
2. [Install the .NET Core 2.1 SDK](https://www.microsoft.com/net/learn/get-started/windows).
2. Clone the source code (see above).
2. Open a `Developer Command Prompt for VS 2019` prompt.
3. Build the code using the `build.cmd` script at the root of the repo. This also restores packages needed to open the projects in Visual Studio.
5. Open `MSBuild.sln` or `MSBuild.Dev.sln` in Visual Studio 2019.

Note: To produce a "bootstrap" build, run `.\build.cmd /p:CreateBootstrap=true`.

### Building MSBuild in Unix (Mac & Linux)

MSBuild can be run on Unix systems that support .NET Core. Set-up instructions can be viewed on the wiki: [Building Testing and Debugging on .Net Core MSBuild](documentation/wiki/Building-Testing-and-Debugging-on-.Net-Core-MSBuild.md)

## Localization

You can turn on localized builds via the `/p:LocalizedBuild=true` command line argument. For more information on localized builds and how to make contributions to MSBuild's translations, see our [localization documentation](documentation/wiki/Localization.md)

## How to Engage, Contribute and Provide Feedback

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

#### Getting Started

Before you contribute, please read through the contributing and developer guides to get an idea of what kinds of pull requests we will or won't accept.

* [Contributing Guide](documentation/wiki/Contributing-Code.md)

* **Developer Guide on:**
   - [.Net Core](documentation/wiki/Building-Testing-and-Debugging-on-.Net-Core-MSBuild.md)
   - [Full Framework](documentation/wiki/Building-Testing-and-Debugging-on-Full-Framework-MSBuild.md)
   - [Mono](documentation/wiki/Building-Testing-and-Debugging-on-Mono-MSBuild.md)

Looking for something to work on? This list of [up for grabs issues](https://github.com/Microsoft/msbuild/issues?q=is%3Aopen+is%3Aissue+label%3Aup-for-grabs) is a great place to start.

You are also encouraged to start a discussion by filing an issue or creating a gist.

### MSBuild Components

* **MSBuild**. [Microsoft.Build.CommandLine](https://docs.microsoft.com/visualstudio/msbuild/msbuild)  is the entrypoint for the Microsoft Build Engine (MSBuild.exe).

* **Microsoft.Build**. The [Microsoft.Build](https://docs.microsoft.com/dotnet/api/?term=Microsoft.Build) namespaces contain types that provide programmatic access to, and control of, the MSBuild engine.

* **Microsoft.Build.Framework**. The [Microsoft.Build.Framework](https://docs.microsoft.com/dotnet/api/microsoft.build.framework) namespace contains the types that define how tasks and loggers interact with the MSBuild engine. For additional information on this component, see our [Microsoft.Build.Framework wiki page](documentation/wiki/Microsoft.Build.Framework.md).

* **Microsoft.Build.Tasks**. The [Microsoft.Build.Tasks](https://docs.microsoft.com/dotnet/api/microsoft.build.tasks) namespace contains the implementation of all tasks shipping with MSBuild.

* **Microsoft.Build.Utilities**. The [Microsoft.Build.Utilities](https://docs.microsoft.com/dotnet/api/microsoft.build.utilities) namespace provides helper classes that you can use to create your own MSBuild loggers and tasks.

### License

MSBuild is licensed under the [MIT license](LICENSE).
