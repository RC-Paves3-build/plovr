# Introduction #

plovr is a local compile daemon for Closure JS and Soy files. It has the Closure Library and Closure Templates bundled with it, so you only need to download a single jar file and point it to your directory full of source code to get started. Once it is up and running, you can point a script tag at plovr that will load your compiled code:

`<script src="http://localhost:9810/compile?id=integration-test&mode=ADVANCED"></script>`

Newer documentation is available on the plovr web site: http://plovr.com/docs.html.

The web site also includes a live demo: http://plovr.com/demo/.

# Requirements #

Requires Java 1.7.

# Running plovr #

First, download the most recent version of plovr from the [downloads](http://code.google.com/p/plovr/downloads/list) page.

Next, create a configuration file to tell plovr where your source code is. Currently, config files are written in JSON, and you can view a [sample config file](http://code.google.com/p/plovr/source/browse/testdata/example/integration-test-config.js) in the repository. Although `//` and `/** */` style comments are not strictly allowed in JSON, they are allowed in plovr config files.

There are three important keys in the root object of the JSON config file: `id`, `paths`, and `inputs`:

```
{
  // This comment is allowed even though it is not valid JSON.
  "id": "integration-test",
  "paths": "testdata",
  "inputs": "testdata/example/main.js"
}
```

  * `id` is the value that will be used with the query parameter `id` in the `src` of the `<script>` tag. plovr can be instantiated with multiple config files, so each must have a unique value for `id`.
  * `paths` is a single string literal (or an array of string literals) that identifies files and directories of JS and Soy files that may be used as dependencies in the compilation. Because the Closure Library and Soy are already bundled with plovr, they are already considered dependencies, so they do not need to be included explicitly. The `paths` parameter is analogous to `--path` in `calcdeps.py`.
  * `inputs` is a single string literal (or an array of string literals) that identifies JS files that must be included in the compilation. The `inputs` parameter is analogous to `--input` in `calcdeps.py`.

The complete set of plovr config options can be seen at http://www.plovr.com/options.html.

Once you have created a config file, start plovr by running:

`java -jar plovr.jar serve <config-file-1> <config-file-2>`

This will start an HTTP server on `localhost:9810`. To get plovr to do the compilation specified in the config file, load the following in a web browser:

`http://localhost:9810/compile?id=ID_FROM_CONFIG_FILE`

By default, code will be compiled using `SIMPLE_OPTIMIZATIONS`, but it is possible to add a `mode` query parameter to override that setting:

`http://localhost:9810/compile?id=ID_FROM_CONFIG_FILE&mode=ADVANCED`

The supported values for `mode` are:

  * `RAW` serves one `<script>` tag per input with the original content.
  * `WHITESPACE` equivalent to the `WHITESPACE_ONLY` compilation level.
  * `SIMPLE` equivalent to the `SIMPLE_OPTIMIZATIONS` compilation level.
  * `ADVANCED` equivalent to the `ADVANCED_OPTIMIZATIONS` compilation level.

Values for `mode` are case-insensitive.

# Building with plovr #

If you just want plovr to write a file, run:

`java -jar plovr.jar build <config-file>`

and it will do its compilation based on the settings in `config-file` and print the results to standard out.

# Other features of plovr when run in server mode #

When the `serve` argument is passed to plovr to run it as a compiler daemon, there are other URLs that you can visit as well to get information about your compilation.

## File Size ##

To see a breakdown of the compiled size of each file, visit:

`http://localhost:9810/size?id=ID_FROM_CONFIG_FILE`

Unfortunately, the UI is not that great right now, but it can help identify where code bloat is coming from.

## Source Map ##

To get the source map of the last compilation done by plovr, visit:

`http://localhost:9810/sourcemap?id=ID_FROM_CONFIG_FILE`

This should make it easier to debug your code with the Closure Inspector.