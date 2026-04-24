.PHONY: deploy prove run

deploy:
	@echo "Deploy: nothing to provision (GitHub Actions worker present)"

run:
	@echo "Trigger workflow from GitHub UI or via API"

prove:
	@test -f receipts/runtime/latest.json && echo "PROVE: PASS" || (echo "PROVE: FAIL" && exit 1)
