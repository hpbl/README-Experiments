# Orchard Core 

Orchard Core consists of two distinct projects:

- __Orchard Core Framework__: An application framework for building modular, multi-tenant applications on ASP.NET Core.
- __Orchard Core CMS__: A Web Content Management System (CMS) built on top of the Orchard Core Framework.

[![Join the chat at https://gitter.im/OrchardCMS/OrchardCore](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/OrchardCMS/OrchardCore?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![BSD-3-Clause License](https://img.shields.io/badge/license-BSD--3--Clause-blue.svg)](LICENSE.txt)
[![Documentation](https://readthedocs.org/projects/orchardcore/badge/)](https://orchardcore.readthedocs.io/en/latest/)
[![Crowdin](https://d322cqt584bo4o.cloudfront.net/orchard-core/localized.svg)](https://crowdin.com/project/orchard-core)


## Build Status

Stable (master): 

[![Build Status](https://api.travis-ci.org/OrchardCMS/OrchardCore.svg?branch=master)](https://travis-ci.org/OrchardCMS/OrchardCore/branches)
[![Build status](https://img.shields.io/appveyor/ci/alexbocharov/orchardcore/master.svg?label=appveyor&style=flat-square)](https://ci.appveyor.com/project/alexbocharov/orchardcore/branch/master)
[![NuGet](https://img.shields.io/nuget/v/OrchardCore.Application.Cms.Targets.svg)](https://www.nuget.org/packages/OrchardCore.Application.Cms.Targets)

Nightly (dev): 

[![Build Status](https://api.travis-ci.org/OrchardCMS/OrchardCore.svg?branch=dev)](https://travis-ci.org/OrchardCMS/OrchardCore/branches)
[![Build status](https://img.shields.io/appveyor/ci/alexbocharov/orchardcore/dev.svg?label=appveyor&style=flat-square)](https://ci.appveyor.com/project/alexbocharov/orchardcore/branch/dev)
[![MyGet](https://img.shields.io/myget/orchardcore-preview/vpre/OrchardCore.Application.Cms.Targets.svg)](https://myget.org/feed/orchardcore-preview/package/nuget/OrchardCore.Application.Cms.Targets)

## Status

### Beta 3

The software is complete enough for external testing -- that is, by groups outside the organization or community that developed the software. Beta software is usually feature complete, but may have known limitations or bugs. Betas are either closed (private) and limited to a specific set of users, or they can be open to the general public.

Here is a more detailed [roadmap](https://github.com/OrchardCMS/OrchardCore/wiki/Roadmap).

## Getting Started

- Clone the repository using the command `git clone https://github.com/OrchardCMS/OrchardCore.git` and checkout the `dev` branch. 

### Command line

- Install the latest versions (current) for both Runtime and SDK of .NET Core from this page https://www.microsoft.com/net/download/core
- Navigate to `D:\OrchardCore\src\OrchardCore.Cms.Web` or wherever your respective folder is on the command line in Administrator mode.
- Call `dotnet run`.
- Then open the `http://localhost:5000` URL in your browser.

### Visual Studio

- Download Visual Studio 2017 or 2019 (any edition) from https://www.visualstudio.com/downloads/
- Open `OrchardCore.sln` and wait for Visual Studio to restore all Nuget packages
- Ensure `OrchardCore.Cms.Web` is the startup project and run it

### Docker

- Run `docker run --name orchardcms orchardproject/orchardcore-cms-linux:latest`

Docker images and parameters can be found at https://hub.docker.com/u/orchardproject/

### Documentation

The documentation can be accessed here: [https://orchardcore.readthedocs.io/en/dev/](https://orchardcore.readthedocs.io/en/dev/)
