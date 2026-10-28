`openapi-3.0.json` is the output of `dlm openapi --oas 3.0` of dlm-server commit
`d8ecf19` (main, 2026-10-29, after P13.1 and P13.11). Replace it with the release asset
`dlm_<version>_openapi-3.0.json` once a release contains P13.1/P13.11, then run
`tool/generate.sh`.
