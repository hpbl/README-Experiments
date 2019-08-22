| :mega: Calling for Maintainers |
|--------------|
| With the introduction of [ASP.NET Core](https://www.asp.net/core), I've now shifted my focus to the Core-specific project - [Swashbuckle.AspNetCore](https://github.com/domaindrivendev/Swashbuckle.AspNetCore). That will be receiving most of my (already limited) personal time, and so I won't have the capacity to maintain this one at a sufficient rate. Still, I'd love to see it live on and am seeking one or two "core" contributors / maintainers to help out. Ideally, these would be people who have already contributed through PRs and understand the inner workings and overall design. Once signed-up, we can agree on an approach that works - ultimately, I want to remove myself as the bottleneck to merging PRs and getting fresh Nugets published. If you're interested, please let me know by adding a comment [here](https://github.com/domaindrivendev/Swashbuckle/issues/1053) |

Swashbuckle
=========

[![Build status](https://ci.appveyor.com/api/projects/status/qoesh4nm6tb6diuk?svg=true)](https://ci.appveyor.com/project/domaindrivendev/swashbuckle)

Seamlessly adds a [Swagger](http://swagger.io/) to WebApi projects! Combines ApiExplorer and Swagger/swagger-ui to provide a rich discovery, documentation and playground experience to your API consumers.

In addition to its Swagger generator, Swashbuckle also contains an embedded version of [swagger-ui](https://github.com/swagger-api/swagger-ui) which it will automatically serve up once Swashbuckle is installed. This means you can complement your API with a slick discovery UI to assist consumers with their integration efforts. Best of all, it requires minimal coding and maintenance, allowing you to focus on building an awesome API!

And that's not all ...

Once you have a Web API that can describe itself in Swagger, you've opened the treasure chest of Swagger-based tools including a client generator that can be targeted to a wide range of popular platforms. See [swagger-codegen](https://github.com/swagger-api/swagger-codegen) for more details.

**Swashbuckle Core Features:**

* Auto-generated [Swagger 2.0](https://github.com/swagger-api/swagger-spec/blob/master/versions/2.0.md)
* Seamless integration of swagger-ui
* Reflection-based Schema generation for describing API types
* Extensibility hooks for customizing the generated Swagger doc
* Extensibility hooks for customizing the swagger-ui
* Out-of-the-box support for leveraging Xml comments
* Support for describing ApiKey, Basic Auth and OAuth2 schemes ... including UI support for the Implicit OAuth2 flow

**Swashbuckle 5.0**

Swashbuckle 5.0 makes the transition to Swagger 2.0. The 2.0 schema is significantly different to its predecessor (1.2) and, as a result, the Swashbuckle config interface has undergone yet another overhaul. Checkout the [transition guide](#transitioning-to-swashbuckle-50) if you're upgrading from a prior version.

## Getting Started ##

There are currently two Nuget packages - the Core library (Swashbuckle.Core) and a convenience package (Swashbuckle)  - that provides automatic bootstrapping. The latter is only applicable to regular IIS hosted Web APIs. For all other hosting environments, you should only install the Core library and then follow the instructions below to manually enable the Swagger routes.

Once installed and enabled, you should be able to browse the following Swagger docs and UI endpoints respectively:

***\<your-root-url\>/swagger/docs/v1***

***\<your-root-url\>/swagger***

### IIS Hosted ###

If your service is hosted in IIS, you can start exposing Swagger docs and a corresponding swagger-ui by simply installing the following Nuget package:

    Install-Package Swashbuckle

This will add a reference to Swashbuckle.Core and also install a bootstrapper (App_Start/SwaggerConfig.cs) that enables the Swagger routes on app start-up using [WebActivatorEx](https://github.com/davidebbo/WebActivator).

### Self-hosted ###

If your service is self-hosted, just install the Core library:

    Install-Package Swashbuckle.Core

Then manually enable the Swagger docs and, optionally, the swagger-ui by invoking the following extension methods (in namespace Swashbuckle.Application) on an instance of HttpConfiguration (e.g. in Program.cs)

```csharp
httpConfiguration
     .EnableSwagger(c => c.SingleApiVersion("v1", "A title for your API"))
     .EnableSwaggerUi();
```

### OWIN  ###

If your service is hosted using OWIN middleware, just install the Core library:

    Install-Package Swashbuckle.Core

Then manually enable the Swagger docs and swagger-ui by invoking the extension methods (in namespace Swashbuckle.Application) on an instance of HttpConfiguration (e.g. in Startup.cs)

```csharp
httpConfiguration
    .EnableSwagger(c => c.SingleApiVersion("v1", "A title for your API"))
    .EnableSwaggerUi();    
```

## Troubleshooting ##

Troubleshooting??? I thought this was all supposed to be "seamless"? OK you've called me out! Things shouldn't go wrong, but if they do, take a look at the [FAQs](#troubleshooting-and-faqs) for inspiration.

## Customizing the Generated Swagger Docs ##

The following snippet demonstrates the minimum configuration required to get the Swagger docs and swagger-ui up and running:
```csharp
httpConfiguration
      .EnableSwagger(c => c.SingleApiVersion("v1", "A title for your API"))
      .EnableSwaggerUi();
```

These methods expose a range of configuration and extensibility options that you can pick and choose from, combining the convenience of sensible defaults with the flexibility to customize where you see fit. Read on to learn more.

### Custom Routes ###

The default route templates for the Swagger docs and swagger-ui are "swagger/docs/{apiVersion}" and "swagger/ui/{\*assetPath}" respectively. You're free to change these so long as the provided templates include the relevant route parameters - {apiVersion} and {\*assetPath}.

```csharp
httpConfiguration
    .EnableSwagger("docs/{apiVersion}/swagger", c => c.SingleApiVersion("v1", "A title for your API"))
    .EnableSwaggerUi("sandbox/{*assetPath}");
```

In this case the URL to swagger-ui will be `sandbox/index`.

### Pretty Print ###

If you want the output Swagger docs to be indented properly, enable the __PrettyPrint__ option as following:

```cs
httpConfiguration
    .EnableSwagger(c => c.PrettyPrint())
    .EnableSwaggerUi();
```

### Additional Service Metadata ###

In addition to operation descriptions, Swagger 2.0 includes several properties to describe the service itself. These can all be provided through the configuration API:

```csharp
httpConfiguration
    .EnableSwagger(c =>
        {
            c.RootUrl(req => GetRootUrlFromAppConfig());

            c.Schemes(new[] { "http", "https" });

            c.SingleApiVersion("v1", "Swashbuckle.Dummy")
                .Description("A sample API for testing and prototyping Swashbuckle features")
                .TermsOfService("Some terms")
                .Contact(cc => cc
                    .Name("Some contact")
                    .Url("http://tempuri.org/contact")
                    .Email("some.contact@tempuri.org"))
                .License(lc => lc
                    .Name("Some License")
                    .Url("http://tempuri.org/license"));
        });
```
#### RootUrl ####

By default, the service root url is inferred from the request used to access the docs. However, there may be situations (e.g. proxy and load-balanced environments) where this does not resolve correctly. You can workaround this by providing your own code to determine the root URL.

#### Schemes ####

If schemes are not explicitly provided in a Swagger 2.0 document, then the scheme used to access the docs is taken as the default. If your API supports multiple schemes and you want to be explicit about them, you can use the __Schemes__ option.

#### SingleApiVersion ####

Use this to describe a single version API. Swagger 2.0 includes an "Info" object to hold additional metadata for an API. Version and title are required but you may also provide additional fields as shown above.

__NOTE__: If your Web API is hosted in IIS, you should avoid using full-stops in the version name (e.g. "1.0"). The full-stop at the tail of the URL will cause IIS to treat it as a static file (i.e. with an extension) and bypass the URL Routing Module and therefore, Web API. 

### Describing Multiple API Versions ###

If your API has multiple versions, use __MultipleApiVersions__ instead of __SingleApiVersion__. In this case, you provide a lambda that tells Swashbuckle which actions should be included in the docs for a given API version. Like __SingleApiVersion__, __Version__ also returns an "Info" builder so you can provide additional metadata per API version.

```csharp
httpConfiguration
    .EnableSwagger(c =>
        {
            c.MultipleApiVersions(
                (apiDesc, targetApiVersion) => ResolveVersionSupportByRouteConstraint(apiDesc, targetApiVersion),
                (vc) =>
                {
                    vc.Version("v2", "Swashbuckle Dummy API V2");
                    vc.Version("v1", "Swashbuckle Dummy API V1");
                });
        });
    .EnableSwaggerUi(c =>
        {
            c.EnableDiscoveryUrlSelector();
        });
```

\* You can also enable a select box in the swagger-ui (as shown above) that displays a discovery URL for each version. This provides a convenient way for users to browse documentation for different API versions.

### Describing Security/Authorization Schemes ###

You can use BasicAuth, __ApiKey__ or __OAuth2__ options to describe security schemes for the API. See https://github.com/swagger-api/swagger-spec/blob/master/versions/2.0.md for more details.

```csharp
httpConfiguration
     .EnableSwagger(c =>
         {
             //c.BasicAuth("basic")
             //    .Description("Basic HTTP Authentication");

             //c.ApiKey("apiKey")
             //    .Description("API Key Authentication")
             //    .Name("apiKey")
             //    .In("header");

             c.OAuth2("oauth2")
                 .Description("OAuth2 Implicit Grant")
                 .Flow("implicit")
                 .AuthorizationUrl("http://petstore.swagger.wordnik.com/api/oauth/dialog")
                 //.TokenUrl("https://tempuri.org/token")
                 .Scopes(scopes =>
                 {
                     scopes.Add("read", "Read access to protected resources");
                     scopes.Add("write", "Write access to protected resources");
                 });

             c.OperationFilter<AssignOAuth2SecurityRequirements>();
         });
     .EnableSwaggerUi(c =>
         {
             c.EnableOAuth2Support("test-client-id", "test-realm", "Swagger UI");
         });
```
__NOTE:__ These only define the schemes and need to be coupled with a corresponding "security" property at the document or operation level to indicate which schemes are required for each operation.  To do this, you'll need to implement a custom IDocumentFilter and/or IOperationFilter to set these properties according to your specific authorization implementation

\* If your API supports the OAuth2 Implicit flow, and you've described it correctly, according to the Swagger 2.0 specification, you can enable UI support as shown above.

### Customize the Operation Listing ###

If necessary, you can ignore obsolete actions and provide custom grouping/sorting strategies for the list of Operations in a Swagger document:

```csharp
httpConfiguration
    .EnableSwagger(c =>
        {
            c.IgnoreObsoleteActions();

            c.GroupActionsBy(apiDesc => apiDesc.HttpMethod.ToString());

            c.OrderActionGroupsBy(new DescendingAlphabeticComparer());
        });
```
#### IgnoreObsoleteActions ####

Set this flag to omit operation descriptions for any actions decorated with the Obsolete attribute

__NOTE__: If you want to omit specific operations but without using the Obsolete attribute, you can create an IDocumentFilter or make use of the built in ApiExplorerSettingsAttribute

#### GroupActionsBy ####

Each operation can be assigned one or more tags which are then used by consumers for various reasons. For example, the swagger-ui groups operations according to the first tag of each operation. By default, this will be the controller name but you can use this method to override with any value.

#### OrderActionGroupsBy ####

You can also specify a custom sort order for groups (as defined by __GroupActionsBy__) to dictate the order in which operations are listed. For example, if the default grouping is in place (controller name) and you specify a descending alphabetic sort order, then actions from a ProductsController will be listed before those from a CustomersController. This is typically used to customize the order of groupings in the swagger-ui.

### Modifying Generated Schemas ###

Swashbuckle makes a best attempt at generating Swagger compliant JSON schemas for the various types exposed in your API. However, there may be occasions when more control of the output is needed.  This is supported through the following options:

```csharp
httpConfiguration
      .EnableSwagger(c =>
          {
              c.MapType<ProductType>(() => new Schema { type = "integer", format = "int32" });

              c.SchemaFilter<ApplySchemaVendorExtensions>();

              //c.UseFullTypeNameInSchemaIds();

              c.SchemaId(t => t.FullName.Contains('`') ? t.FullName.Substring(0, t.FullName.IndexOf('`')) : t.FullName);
              
              c.IgnoreObsoleteProperties();

              c.DescribeAllEnumsAsStrings();
          });
```

#### MapType ####

Use this option to override the Schema generation for a specific type.

It should be noted that the resulting Schema will be placed "inline" for any applicable Operations. While Swagger 2.0 supports inline definitions for "all" Schema types, the swagger-ui tool does not. It expects "complex" Schemas to be defined separately and referenced. For this reason, you should only use the __MapType__ option when the resulting Schema is a primitive or array type.

If you need to alter a complex Schema, use a Schema filter.

#### SchemaFilter ####

If you want to post-modify "complex" Schemas once they've been generated, across the board or for a specific type, you can wire up one or more Schema filters.

ISchemaFilter has the following interface:

```csharp
void Apply(Schema schema, SchemaRegistry schemaRegistry, Type type);
```

A typical implementation will inspect the system Type and modify the Schema accordingly. If necessary, the schemaRegistry can be used to obtain or register Schemas for other Types

#### UseFullTypeNamesInSchemaIds ####

In a Swagger 2.0 document, complex types are typically declared globally and referenced by unique Schema Id. By default, Swashbuckle does NOT use the full type name in Schema Ids. In most cases, this works well because it prevents the "implementation detail" of type namespaces from leaking into your Swagger docs and UI. However, if you have multiple types in your API with the same class name, you'll need to opt out of this behavior to avoid Schema Id conflicts.  

#### SchemaId ####

Use this option to provide your own custom strategy for inferring SchemaId's for describing "complex" types in your API.

#### IgnoreObsoleteProperties ####

Set this flag to omit schema property descriptions for any type properties decorated with the Obsolete attribute 

#### DescribeAllEnumsAsStrings ####

In accordance with the built in JsonSerializer, Swashbuckle will, by default, describe enums as integers. You can change the serializer behavior by configuring the StringEnumConverter globally or for a given enum type. Swashbuckle will honor this change out-of-the-box. However, if you use a different approach to serialize enums as strings, you can also force Swashbuckle to describe them as strings.

### Modifying Generated Operations ###

Similar to Schema filters, Swashbuckle also supports Operation and Document filters:

```csharp
httpConfiguration
     .EnableSwagger(c => c.SingleApiVersion("v1", "A title for your API"))
         {
             c.OperationFilter<AddDefaultResponse>();

             c.DocumentFilter<ApplyDocumentVendorExtensions>();
         });
```
#### OperationFilter ####

Post-modify Operation descriptions once they've been generated by wiring up one or more Operation filters.

IOperationFilter has the following interface:

```csharp
void Apply(Operation operation, SchemaRegistry schemaRegistry, ApiDescription apiDescription);
```

A typical implementation will inspect the ApiDescription and modify the Operation accordingly. If necessary, the schemaRegistry can be used to obtain or register Schemas for Types that are used in the Operation.

#### DocumentFilter ####

Post-modify the entire Swagger document by wiring up one or more Document filters.

IDocumentFilter has the following interface:

```csharp
void Apply(SwaggerDocument swaggerDoc, SchemaRegistry schemaRegistry, IApiExplorer apiExplorer);
```

This gives full control to modify the final SwaggerDocument. You can gain additional context from the provided SwaggerDocument (e.g. version) and IApiExplorer. You should have a good understanding of the [Swagger 2.0 spec.](https://github.com/swagger-api/swagger-spec/blob/master/versions/2.0.md) before using this option.

### Wrapping the SwaggerGenerator with Additional Behavior ###

The default implementation of ISwaggerProvider, the interface used to obtain Swagger metadata for a given API, is the SwaggerGenerator. If neccessary, you can inject your own implementation or wrap the existing one with additional behavior. For example, you could use this option to inject a "Caching Proxy" that attempts to retrieve the SwaggerDocument from a cache before delegating to the built-in generator:

```csharp
httpConfiguration
      .EnableSwagger(c => c.SingleApiVersion("v1", "A title for your API"))
          {
        c.CustomProvider((defaultProvider) => new CachingSwaggerProvider(defaultProvider));
          });
```

### Including XML Comments ###

If you annotate Controllers and API Types with [Xml Comments](http://msdn.microsoft.com/en-us/library/b2s063f7(v=vs.110).aspx), you can incorporate those comments into the generated docs and UI. The Xml tags are mapped to Swagger properties as follows:

* **Action summary** -> Operation.summary
* **Action remarks** -> Operation.description
* **Parameter summary** -> Parameter.description
* **Type summary** -> Schema.descripton
* **Property summary** -> Schema.description (i.e. on a property Schema)

You can enable this by providing the path to one or more XML comments files:
```csharp
httpConfiguration
    .EnableSwagger(c =>
        {
            c.SingleApiVersion("v1", "A title for your API");
            c.IncludeXmlComments(GetXmlCommentsPathForControllers());
            c.IncludeXmlComments(GetXmlCommentsPathForModels());
        });
```

NOTE: You will need to enable output of the XML documentation file. This is enabled by going to project properties -> Build -> Output. The "XML documentation file" needs to be checked and a path assigned, such as "bin\Debug\MyProj.XML". You will also want to verify this across each build configuration. Here's an example of reading the file, but it may need to be modified according to your specific project settings:

```csharp
httpConfiguration
    .EnableSwagger(c =>
        {
            var baseDirectory = AppDomain.CurrentDomain.BaseDirectory;
            var commentsFileName = Assembly.GetExecutingAssembly().GetName().Name + ".XML";
            var commentsFile = Path.Combine(baseDirectory, commentsFileName);

            c.SingleApiVersion("v1", "A title for your API");
            c.IncludeXmlComments(commentsFile);
            c.IncludeXmlComments(GetXmlCommentsPathForModels());
        });
```
#### Response Codes ####

Swashbuckle will automatically create a "success" response for each operation based on the action's return type. If it's a void, the status code will be 204 (No content), otherwise 200 (Ok). This mirrors WebApi's default behavior. If you need to change this and/or list additional response codes, you can use the non-standard "response" tag:

```csharp
/// <response code="201">Account created</response>
/// <response code="400">Username already in use</response>
public int Create(Account account)
```
### Working Around Swagger 2.0 Constraints ###

In contrast to Web API, Swagger 2.0 does not include the query string component when mapping a URL to an action. As a result, Swashbuckle will raise an exception if it encounters multiple actions with the same path (sans query string) and HTTP method. You can workaround this by providing a custom strategy to pick a winner or merge the descriptions for the purposes of the Swagger docs 

```csharp
httpConfiguration
    .EnableSwagger((c) =>
        {
            c.SingleApiVersion("v1", "A title for your API"));
            c.ResolveConflictingActions(apiDescriptions => apiDescriptions.First());
        });
```
See the following discussion for more details:

<https://github.com/domaindrivendev/Swashbuckle/issues/142>

## Customizing the swagger-ui ##

The swagger-ui is a JavaScript application hosted in a single HTML page (index.html), and it exposes several customization settings. Swashbuckle ships with an embedded version and includes corresponding configuration methods for each of the UI settings. If you require further customization, you can also inject your own version of "index.html". Read on to learn more.

### Customizations via the configuration API ###

If you're happy with the basic look and feel but want to make some minor tweaks, the following options may be sufficient:

```csharp
httpConfiguration
    .EnableSwagger(c => c.SingleApiVersion("v1", "A title for your API"))
    .EnableSwaggerUi(c =>
        {
            c.InjectStylesheet(containingAssembly, "Swashbuckle.Dummy.SwaggerExtensions.testStyles1.css");
            c.InjectJavaScript(containingAssembly, "Swashbuckle.Dummy.SwaggerExtensions.testScript1.js");
            c.SetValidatorUrl("http://localhost/validator");
            c.DisableValidator();
            c.DocExpansion(DocExpansion.List);
            c.SupportedSubmitMethods("GET", "HEAD")
        });
```

#### InjectStylesheet ####

Use this to enrich the UI with one or more additional CSS stylesheets. The file(s) must be included in your project as an "Embedded Resource", and then the resource's "Logical Name" is passed to the method as shown above. See [Injecting Custom Content](#injecting-custom-content) for step by step instructions.

#### InjectJavaScript ####

Use this to invoke one or more custom JavaScripts after the swagger-ui has loaded. The file(s) must be included in your project as an "Embedded Resource", and then the resource's "Logical Name" is passed to the method as shown above. See [Injecting Custom Content](#injecting-custom-content) for step by step instructions.

#### SetValidatorUrl/DisableValidator ####

By default, swagger-ui will validate specs against swagger.io's online validator and display the result in a badge at the bottom of the page. Use these options to set a different validator URL or to disable the feature entirely.

#### DocExpansion ####

Use this option to control how the Operation listing is displayed. It can be set to "None" (default), "List" (shows operations for each resource), or "Full" (fully expanded: shows operations and their details).

#### SupportedSubmitMethods ####

Specify which HTTP operations will have the 'Try it out!' option. An empty parameter list disables it for all operations.

### Provide your own "index" file ###

As an alternative, you can inject your own version of "index.html" and customize the markup and swagger-ui directly. Use the __CustomAsset__ option to instruct Swashbuckle to return your version instead of the default when a request is made for "index". As with all custom content, the file must be included in your project as an "Embedded Resource", and then the resource's "Logical Name" is passed to the method as shown below. See [Injecting Custom Content](#injecting-custom-content) for step by step instructions.

For compatibility, you should base your custom "index.html" off [this version](https://github.com/domaindrivendev/Swashbuckle/blob/v5.5.3/Swashbuckle.Core/SwaggerUi/CustomAssets/index.html)

```csharp
httpConfiguration
     .EnableSwagger(c => c.SingleApiVersion("v1", "A title for your API"))
     .EnableSwaggerUi(c =>
         {
             c.CustomAsset("index", yourAssembly, "YourWebApiProject.SwaggerExtensions.index.html");
         });
```

### Injecting Custom Content ###

The __InjectStylesheet__, __InjectJavaScript__ and __CustomAsset__ options all share the same mechanism for providing custom content. In each case, the file must be included in your project as an "Embedded Resource". The steps to do this are described below:

1. Add a new file to your Web API project.
2. In Solution Explorer, right click the file and open its properties window. Change the "Build Action" to "Embedded Resource".

This will embed the file in your assembly and register it with a "Logical Name". This can then be passed to the relevant configuration method. It's based on the Project's default namespace, file location and file extension. For example, given a default namespace of "YourWebApiProject" and a file located at "/SwaggerExtensions/index.html", then the resource will be assigned the name - "YourWebApiProject.SwaggerExtensions.index.html". If you use "Swagger" as the root folder name for your custom assets, this will collide with the default route templates and the page will not be loaded correctly.

## Transitioning to Swashbuckle 5.0 ##

This version of Swashbuckle makes the transition to Swagger 2.0. The 2.0 specification is significantly different to its predecessor (1.2) and forces several breaking changes to Swashbuckle's configuration API. If you're using Swashbuckle without any customizations, i.e. App_Start/SwaggerConfig.cs has never been modified, then you can overwrite it with the new version. The defaults are the same and so the swagger-ui should behave as before.

\* If you have consumers of the raw Swagger document, you should ensure they can accept Swagger 2.0 before making the upgrade.

If you're using the existing configuration API to customize the final Swagger document and/or swagger-ui, you will need to port the code manually. The static __Customize__ methods on SwaggerSpecConfig and SwaggerUiConfig have been replaced with extension methods on HttpConfiguration - __EnableSwagger__ and __EnableSwaggerUi__. All options from version 4.0 are made available through these methods, albeit with slightly different naming and syntax. Refer to the tables below for a summary of changes:


| 4.0 | 5.0 Equivalent | Additional Notes |
| --------------- | --------------- | ---------------- |
| ResolveBasePathUsing | RootUrl | |
| ResolveTargetVersionUsing | N/A | version is now implicit in the docs URL e.g. "swagger/docs/{apiVersion}" |
| ApiVersion | SingleApiVersion| now supports additional metadata for the version | 
| SupportMultipleApiVersions | MultipleApiVersions | now supports additional metadata for each version |
| Authorization | BasicAuth/ApiKey/OAuth2 | | 
| GroupDeclarationsBy | GroupActionsBy | |
| SortDeclarationsBy | OrderActionGroupsBy | |
| MapType | MapType | now accepts Func&lt;Schema&gt; instead of Func&lt;DataType&gt; |
| ModelFilter | SchemaFilter | IModelFilter is now ISchemaFilter, DataTypeRegistry is now SchemaRegistry |
| OperationFilter | OperationFilter | DataTypeRegistry is now SchemaRegistry |
| PolymorphicType | N/A | not currently supported |
| SupportHeaderParams | N/A | header params are implicitly supported |
| SupportedSubmitMethods | N/A | all HTTP verbs are implicitly supported |
| CustomRoute | CustomAsset | &nbsp; |

## Troubleshooting and FAQ's ##

1. [Swagger-ui showing "Can't read swagger JSON from ..."](#swagger-ui-showing-cant-read-swagger-json-from)
2. [Page not found when accessing the UI](#page-not-found-when-accessing-the-ui)
3. [Swagger-ui broken by Visual Studio 2013](#swagger-ui-broken-by-visual-studio-2013)
4. [OWIN Hosted in IIS - Incorrect VirtualPathRoot Handling](#owin-hosted-in-iis---incorrect-virtualpathroot-handling)
5. [How to add vendor extensions](#how-to-add-vendor-extensions)
6. [FromUri Query string DataMember names are incorrect](#fromuri-query-string-datamember-names-are-incorrect)
7. [Remove Duplicate Path Parameters](#remove-duplicate-path-parameters)
8. [Deploying behind Load Balancer / Reverse Proxies](#deploying-behind-load-balancer--reverse-proxies)
9. [500 : {"Message":"An error has occurred."}](#500--messagean-error-has-occurred)

### Swagger-ui showing "Can't read swagger JSON from ..."

If you see this message, it means the swagger-ui received an unexpected response when requesting the Swagger document. You can troubleshoot further by navigating directly to the discovery URL included in the error message. This should provide more details.

If the discovery URL returns a 404 Not Found response, it may be due to a full-stop in the version name (e.g. "1.0"). This will cause IIS to treat it as a static file (i.e. with an extension) and bypass the URL Routing Module and therefore, Web API. 

To workaround, you can update the version name specified in SwaggerConfig.cs. For example, to "v1", "1-0" etc. Alternatively, you can change the route template being used for the swagger docs (as shown [here](#custom-routes)) so that the version parameter is not at the end of the route.

### Page not found when accessing the UI ###

Swashbuckle serves an embedded version of the swagger-ui through the Web API pipeline. But, most of the URLs contain extensions (.html, .js, .css) and many IIS environments are configured to bypass the managed pipeline for paths containing extensions.

In previous versions of Swashbuckle, this was resolved by adding the following setting to your Web.config:

```xml
<system.webServer>
  <modules runAllManagedModulesForAllRequests="true" />
</system.webServer>
```

This is no longer neccessary in Swashbuckle 5.0 because it serves the swagger-ui through extensionless URL's.

However, if you're using the SingleApiVersion, MultipleApiVersions or CustomAsset configuration settings you could still get this error. Check to ensure you're not specifying a value that causes a URL with an extension to be referenced in the UI. For example a full-stop in a version number ...

```csharp
httpConfiguration
    .EnableSwagger(c => c.SingleApiVersion("1.0", "A title for your API"))
    .EnableSwaggerUi();
```
will result in a discovery URL like this "/swagger/docs/1.0" where the full-stop is treated as a file extension.

### Swagger-ui broken by Visual Studio 2013 ###

VS 2013 ships with a new feature - Browser Link - that improves the web development workflow by setting up a channel between the IDE and pages being previewed in a local browser. It does this by dynamically injecting JavaScript into your files.

Although this JavaScript SHOULD have no affect on your production code, it appears to be breaking the swagger-ui.

I hope to find a permanent fix, but in the meantime, you'll need to workaround this issue by disabling the feature in your web.config:

```xml
<appSettings>
    <add key="vs:EnableBrowserLink" value="false"/>
</appSettings>
```
### OWIN Hosted in IIS - Incorrect VirtualPathRoot Handling

When you host Web API 2 on top of OWIN/SystemWeb, Swashbuckle cannot correctly resolve VirtualPathRoot by default.

You must either explicitly set VirtualPathRoot in your HttpConfiguration at startup, or perform customization like this to fix automatic discovery:

```csharp
httpConfiguration.EnableSwagger(c => 
{
    c.RootUrl(req =>
        req.RequestUri.GetLeftPart(UriPartial.Authority) +
        req.GetRequestContext().VirtualPathRoot.TrimEnd('/'));
}
```

### How to add vendor extensions

Swagger 2.0 allows additional meta-data (aka vendor extensions) to be added at various points in the Swagger document. Swashbuckle supports this by including a "vendorExtensions" dictionary with each of the extensible Swagger types. Meta-data can be added to these dictionaries from custom Schema, Operation or Document filters. For example:

```csharp
public class ApplySchemaVendorExtensions : ISchemaFilter
{
    public void Apply(Schema schema, SchemaRegistry schemaRegistry, Type type)
    {
        schema.vendorExtensions.Add("x-foo", "bar");
    }
}
```

As per the specification, all extension properties should be prefixed by "x-"

### FromUri Query string DataMember names are incorrect

When using `FromUri` Model Binding, it is possible to override the querystring parameter name's using `DataMember`s. In this case you can add a custom operation filter to override the name. For example:

```csharp
public class ComplexTypeOperationFilter : IOperationFilter
{
    public void Apply(Operation operation, SchemaRegistry schemaRegistry, ApiDescription apiDescription)
    {
        if (operation.parameters == null)
            return;

        var parameters = apiDescription.ActionDescriptor.GetParameters();
        foreach (var parameter in parameters)
        {
            foreach (var property in parameter.ParameterType.GetProperties())
            {
                var param = operation.parameters.FirstOrDefault(o => o.name.ToLowerInvariant().Contains(property.Name.ToLowerInvariant()));

                if (param == null) continue;

                var name = GetNameFromAttribute(property);

                if (string.IsNullOrEmpty(name))
                {
                    operation.parameters.Remove(param);
                }
                param.name = GetNameFromAttribute(property);
            }
        }
    }
    
    private static string GetNameFromAttribute(PropertyInfo property)
    {
        var customAttributes = property.GetCustomAttributes(typeof(DataMemberAttribute), true);
        if (customAttributes.Length > 0)
        {
            var attribute = customAttributes[0] as DataMemberAttribute;
            if (attribute != null) return attribute.Name;
        }
        return string.Empty;
    }
}
```

### Remove Duplicate Path Parameters

When using `FromUri` Model Binding, duplicate items can appear as items can be passed as URI parameters, or querystrings. In this case you can add a custom operation filter to remove the duplicates. For example:

```csharp
public class ComplexTypeOperationFilter : IOperationFilter
{
    public void Apply(Operation operation, SchemaRegistry schemaRegistry, ApiDescription apiDescription)
    {
       if (operation.parameters == null)
           return;
       var complexParameters = operation.parameters.Where(x => x.@in == "query" && !string.IsNullOrWhiteSpace(x.name)).ToArray();

       foreach (var parameter in complexParameters)
       {
           if (!parameter.name.Contains('.')) continue;
           var name = parameter.name.Split('.')[1];

           var opParams = operation.parameters.Where(x => x.name == name);
           var parameters = opParams as Parameter[] ?? opParams.ToArray();

           if (parameters.Length > 0)
           {
               operation.parameters.Remove(parameter);
           }
       }
    }
}
```

### Deploying behind Load Balancer / Reverse Proxies

Swashbuckle attempts to populate the [Swagger "host"](http://swagger.io/specification/#swaggerObject) property from HTTP headers that are sent with the request for Swagger JSON. This may cause issues in load balancer / reverse proxy environments, particularly if non-standard headers are used to pass on the outer most host name. You can workaround this by providing your own function for determining your API's root URL based on vendor-specific headers. Checkout [issue 705](https://github.com/domaindrivendev/Swashbuckle/issues/705) for some potential implementations.

### 500 : {"Message":"An error has occurred."}

If, on loading the Swagger UI page, you get an error: `500 : {"Message":"An error has occurred."} http://<url>/swagger/docs/v1` ensure that the XML documentation output settings have been set in the project file in the solution, for both Debug and Release configurations.
