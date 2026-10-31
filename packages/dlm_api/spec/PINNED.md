`openapi-3.0.json` is the release asset `dlm_0.7.0_openapi-3.0.json` of dlm-server v0.7.0
(it contains P13.1–P13.14 and P14.1–P14.8: pairing, extension tokens, capture and refresh
additions). v0.7.0 keeps that contract and lets an extension token move tasks and
end turbo. v0.7.1 has the same contract (it confines extension tokens and hides
captured secrets from read tokens), so the spec was not regenerated. To update, replace it with the asset of a newer release and run
`tool/generate.sh`.
