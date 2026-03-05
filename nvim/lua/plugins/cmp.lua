local is_devvm = vim.fn.isdirectory("/usr/share/fb-editor-support/nvim") ~= 0

local function needs_proxy()
  if not is_devvm then
    return false
  end
  local ok, config = pcall(require, "meta.config")
  if not ok then
    return false
  end
  local config_exts = config.options.lsp.vscode_extensions
  return not (
    vim.fn.isdirectory(config_exts.macos_app_dir) ~= 0
    or vim.fn.isdirectory(config_exts.fedora_app_dir) ~= 0
  )
end

-- Base blink.cmp config
local opts = {
  fuzzy = {
    prebuilt_binaries = {
      extra_curl_args = needs_proxy()
          and { "--proxy", "http://fwdproxy:8080" }
        or {},
    },
  },
}

-- Add Meta completion sources only on DevVM
if is_devvm then
  opts.sources = {
    default = {
      "meta_title",
      "meta_tags",
      "meta_tasks",
      "meta_revsub",
    },
    providers = {
      meta_title = { name = "MetaTitle", module = "meta.cmp.title" },
      meta_tags = { name = "MetaTags", module = "meta.cmp.tags" },
      meta_tasks = { name = "MetaTasks", module = "meta.cmp.tasks" },
      meta_revsub = { name = "MetaRevSub", module = "meta.cmp.revsub" },
    },
  }
end

local deps = is_devvm and { "meta.nvim" } or {}

return {
  {
    "saghen/blink.cmp",
    dependencies = deps,
    version = "1.*",
    opts = opts,
    opts_extend = { "sources.default" },
  },
}
