{
  lib,
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "vacuum-go";
  version = "0.30.0";

  src = fetchFromGitHub {
    owner = "daveshanley";
    repo = "vacuum";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jWOCStvDpY+luK17H09qysveMXCW+LYbXk+/1Y/4zgs=";
  };

  vendorHash = "sha256-GOZNxnzk0rpm+rWKSEVsgVyITQRV6hv+sOwOQ9dByF4=";

  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
    "-X main.version=v${finalAttrs.version}"
  ];

  tags = [ "html_report_ui" ];

  preBuild = ''
    mkdir -p html-report/ui/build/static/js
    cp ${finalAttrs.passthru.htmlReportUI}/static/js/vacuumReport.js html-report/ui/build/static/js/
    cp ${finalAttrs.passthru.htmlReportUI}/static/js/hydrate.js html-report/ui/build/static/js/
  '';

  subPackages = [ "./vacuum.go" ];

  passthru = {
    # see upstream scripts/build-ui-assets.sh
    htmlReportUI = buildNpmPackage {
      pname = "vacuum-html-report-ui";
      inherit (finalAttrs) version src;

      sourceRoot = "${finalAttrs.src.name}/html-report/ui";

      npmDepsHash = "sha256-d7bedNSUt+6Ge9vTQf5CbxzCjkS+j32gwC48m+6CxzY=";

      installPhase = ''
        runHook preInstall
        cp -r build "$out"
        runHook postInstall
      '';
    };

    tests.version = testers.testVersion {
      package = finalAttrs.finalPackage;
      command = "vacuum version";
      version = "v${finalAttrs.version}";
    };
  };

  meta = {
    description = "World's fastest OpenAPI & Swagger linter";
    homepage = "https://quobix.com/vacuum";
    changelog = "https://github.com/daveshanley/vacuum/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "vacuum";
    maintainers = with lib.maintainers; [ konradmalik ];
  };
})
