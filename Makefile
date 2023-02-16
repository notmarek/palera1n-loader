TARGET_CODESIGN = $(shell command -v ldid)

P1TMP          = $(TMPDIR)/pokem0nloader
P1_STAGE_DIR   = $(P1TMP)/stage
P1_APP_DIR 	   = $(P1TMP)/Build/Products/Release-iphoneos/pokem0nLoader.app
P1_HELPER_PATH = $(P1TMP)/Build/Products/Release-iphoneos/pokem0nHelper

.PHONY: package

package:
	
	# Build
	@set -o pipefail; \
		xcodebuild -jobs $(shell sysctl -n hw.ncpu) -project 'pokem0nLoader.xcodeproj' -scheme pokem0nLoader -configuration Release -arch arm64 -sdk iphoneos -derivedDataPath $(P1TMP) \
		CODE_SIGNING_ALLOWED=NO DSTROOT=$(P1TMP)/install ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO
		
	@set -o pipefail; \
		xcodebuild -jobs $(shell sysctl -n hw.ncpu) -project 'pokem0nLoader.xcodeproj' -scheme pokem0nHelper -configuration Release -arch arm64 -sdk iphoneos -derivedDataPath $(P1TMP) \
		CODE_SIGNING_ALLOWED=NO DSTROOT=$(P1TMP)/install ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO
	
	@rm -rf Payload
	@rm -rf $(P1_STAGE_DIR)/
	@mkdir -p $(P1_STAGE_DIR)/Payload
	@mv $(P1_APP_DIR) $(P1_STAGE_DIR)/Payload/pokem0nLoader.app

	# Package
	@echo $(P1TMP)
	@echo $(P1_STAGE_DIR)

	@mv $(P1_HELPER_PATH) $(P1_STAGE_DIR)/Payload/pokem0nLoader.app/pokem0nHelper
	@$(TARGET_CODESIGN) -Sentitlements.plist $(P1_STAGE_DIR)/Payload/pokem0nLoader.app/
	@$(TARGET_CODESIGN) -Sentitlements.plist $(P1_STAGE_DIR)/Payload/pokem0nLoader.app/pokem0nHelper
	
	@rm -rf $(P1_STAGE_DIR)/Payload/pokem0nLoader.app/_CodeSignature

	@ln -sf $(P1_STAGE_DIR)/Payload Payload

	@rm -rf packages
	@mkdir -p packages

	@zip -r9 packages/pokem0n.ipa Payload
	@rm -rf Payload
