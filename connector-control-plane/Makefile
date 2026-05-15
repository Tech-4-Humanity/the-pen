.PHONY: install typecheck synth diff deploy schema seed indexes promote bootstrap clean

install:
	cd cdk && npm ci

typecheck:
	cd cdk && npx tsc --noEmit

synth:
	cd cdk && npx cdk synth --all

diff:
	cd cdk && npx cdk diff --all

deploy:
	cd cdk && npx cdk deploy --all --require-approval never

schema:
	psql "$$SUPABASE_DB_URL" -f db/001_schema.sql

seed:
	psql "$$SUPABASE_DB_URL" -f db/002_seed.sql

indexes:
	psql "$$SUPABASE_DB_URL" -f db/003_indexes.sql

promote:
	@echo "Bridge promotion payload:"
	@cat bridge/promote.json

bootstrap: install typecheck schema seed indexes synth deploy
	@echo "CCP bootstrap complete. Verify with: aws lambda invoke --function-name ccp-health-worker /tmp/out.json"

clean:
	cd cdk && rm -rf cdk.out node_modules dist
