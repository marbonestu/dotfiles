local config = require("lsp.utils").make_default_config()
local root_markers = { 'gradlew', '.git' }
local root_dir = require('jdtls.setup').find_root(root_markers)
local jdtls = require("jdtls")
local home = os.getenv('HOME')
local workspace_folder = home .. "/.local/share/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

local jdtls_install_location = home .. '/.local/share/nvim/lsp_servers/jdtls'

local config_system = ""

if vim.fn.has "mac" == 1 then
  config_system = "mac"
elseif vim.fn.has "linux" == 1 then
  config_system = "linux"
end

config.cmd = {
  'java',

  '-Declipse.application=org.eclipse.jdt.ls.core.id1',
  '-Dosgi.bundles.defaultStartLevel=4',
  '-Declipse.product=org.eclipse.jdt.ls.core.product',
  '-Dlog.protocol=true',
  '-Dlog.level=ALL',

  '-Xms1g',
  '--add-modules=ALL-SYSTEM',
  '--add-opens', 'java.base/java.util=ALL-UNNAMED',
  '--add-opens', 'java.base/java.lang=ALL-UNNAMED',


  '-jar', vim.fn.glob(jdtls_install_location .. '/plugins/org.eclipse.equinox.launcher_*.jar'),

  '-configuration', jdtls_install_location .. '/config_' .. config_system,

  '-data', workspace_folder
}


-- This is the default if not provided, you can remove it. Or adjust as needed.
-- One dedicated LSP server & client will be started per unique root_dir
config.root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew' })


-- Here you can configure eclipse.jdt.ls specific settings
-- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
-- for a list of options

config.settings = {
  java = {
    signatureHelp = { enabled = true };
    contentProvider = { preferred = 'fernflower' };
    completion = {
      favoriteStaticMembers = {
        "org.hamcrest.MatcherAssert.assertThat",
        "org.hamcrest.Matchers.*",
        "org.hamcrest.CoreMatchers.*",
        "org.junit.jupiter.api.Assertions.*",
        "java.util.Objects.requireNonNull",
        "java.util.Objects.requireNonNullElse",
        "org.mockito.Mockito.*"
      },

      filteredTypes = {
        "com.sun.*",
        "io.micrometer.shaded.*",
        "java.awt.*",

        "jdk.*",
        "sun.*",
      },

    };
    sources = {
      organizeImports = {
        starThreshold = 9999;
        staticStarThreshold = 9999;
      };

    };
    codeGeneration = {
      toString = {
        template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
      },
      hashCodeEquals = {

        useJava7Objects = true,
      },

      useBlocks = true,
    };
    configuration = {
      runtimes = {
        -- {
        --   name = "JavaSE-1.8",
        --   path = "/usr/lib/jvm/java-8-openjdk/",
        -- },
        -- {
        --   name = "JavaSE-11",
        --   path = "/usr/lib/jvm/java-11-openjdk/",
        -- },
        -- {
        --   name = "JavaSE-16",
        --   path = home .. "/.local/jdks/jdk-16.0.1+9/",
        -- },
        {
          name = "JavaSE-17",
          path = "/usr/local/jvm/java-17-openjdk-amd64",
        },

      }
    };
  };
}

config.on_attach = function(client, bufnr)
  require("lsp.utils").common_on_attach(client, bufnr)

  jdtls.setup_dap({ hotcodereplace = 'auto' })
  jdtls.setup.add_commands()

end

-- Language server `initializationOptions`
-- You need to extend the `bundles` with paths to jar files
-- if you want to use additional eclipse.jdt.ls plugins.
--
-- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
--
-- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this

config.init_options = {
  bundles = {}
}

require('jdtls').start_or_attach(config)
