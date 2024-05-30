local module = {}

--[[function module.PreInit()
	_G.MX_SETTINGS.ESP.Mode = 1
end]]

function module.Init()
	local API = ReplicatedStorage:WaitForChild("API")
	
	do -- Fsys decryptor agent
		print("Decrypting Fsys...")
	
		local API_Dump = {
			LoadAPI = {
				[1] = "GetUIResources",
				[2] = "GetFileLoadStatus",
				[3] = "ReleaseUIResources",
				[4] = "ClientLoadFinished",
				[5] = "GetAssets"
			},
			VehicleAPI = {
				[1] = "IceCreamTruckHornStarted",
				[2] = "SetVehicleCFrame",
				[3] = "StartVehicleControl",
				[4] = "RequestRide",
				[5] = "BuyIceCreamCone",
				[6] = "StartControlVehicle",
				[7] = "SetTaxiFarePrice",
				[8] = "StartRequestRide",
				[9] = "CompleteRide",
				[10] = "StartIceCreamTruckHorn",
				[11] = "SitPetInVehicle",
				[12] = "DespawnVehicle",
				[13] = "RideFinished",
				[14] = "JumpOutOfCar",
				[15] = "ClientRename",
				[16] = "TruckDoorSetIsOpen",
				[17] = "SetSprayParticleEnabled",
				[18] = "CancelRequestRide",
				[19] = "RideStarted",
				[20] = "SitInVehicle",
				[21] = "SetIceCreamConePrice"
			},
			PlayerProfileAPI = {
				[1] = "SaveProfileSlot",
				[2] = "ReportProfile",
				[3] = "SendPlayerLog",
				[4] = "FetchProfile",
				[5] = "UpdateProfileStickers",
				[6] = "TryClaimFreeItem",
				[7] = "FilterText",
				[8] = "UpdateProfileProperties",
				[9] = "RefreshProfile"
			},
			SoundAPI = {
				[1] = "GetSoundDB"
			},
			ErrorReportAPI = {
				[1] = "TradeDebugStashInfiniteConfirmation",
				[2] = "SendUniqueError"
			},
			TeamAPI = {
				[1] = "ChooseTeam",
				[2] = "Spawn"
			},
			PetObjectAPI = {
				[1] = "ClaimFoodObject",
				[2] = "SpawnInFrontOfPet",
				[3] = "CreateFoodCannonObject",
				[4] = "GrabPetObject",
				[5] = "TriggerSqueakEffect",
				[6] = "DropPetObject",
				[7] = "SqueakEffectTriggered",
				[8] = "CreatePetObject"
			},
			LocalizationAPI = {
				[1] = "ResyncLocalization"
			},
			ProductsAPI = {
				[1] = "PromptGamepassPurchase",
				[2] = "GetClientPurchasePrice",
				[3] = "PromptProductPurchase",
				[4] = "CurrencyPurchaseComplete",
				[5] = "SproutCurrency",
				[6] = "CurrencySproutedOutOfCharacterEffect"
			},
			BackpackAPI = {
				[1] = "CommitBackpackItemSet"
			},
			TokenizerAPI = {
				[1] = "GetToken"
			},
			AnalyticsAPI = {
				[1] = "SetClientProperties"
			},
			EventAPI = {
				[1] = "GetServerTime",
				[2] = "ClaimObbyReward",
				[3] = "FireworksStarted",
				[4] = "FlyLantern",
				[5] = "ClaimUncommonPet",
				[6] = "TakePridePin",
				[7] = "ClaimGardenBadge",
				[8] = "StartObby",
				[9] = "ClaimBeesBlaster",
				[10] = "ToggleRainBridge",
				[11] = "CollectSunflowerDrops",
				[12] = "BuyFireworks",
				[13] = "ClaimDailyGift",
				[14] = "TakeEcoPin",
				[15] = "CollectSundrops",
				[16] = "SnowballShot",
				[17] = "CheckDailyGiftAvailable",
				[18] = "ShootSnowball"
			},
			JournalAPI = {
				[1] = "CommitCollection"
			},
			LootBoxAPI = {
				[1] = "ExchangeItemForReward",
				[2] = "RequestPublicDBEntries"
			},
			RoleplayAPI = {
				[1] = "SendToJail",
				[2] = "SetArrestImmunity",
				[3] = "CrushFurniture",
				[4] = "ThrowFurniture",
				[5] = "RobberEntered",
				[6] = "WasHandcuffed",
				[7] = "AbandonRoleplayRole",
				[8] = "PizzaShopDriveThroughRejected",
				[9] = "WasSentToJail",
				[10] = "RenderSourceFurnitureAsStolen",
				[11] = "HandcuffPlayer",
				[12] = "RemoveRoleplayOutfit",
				[13] = "NotifyRobberEntered",
				[14] = "EscapeHandcuffs",
				[15] = "CriminalBaseballBatHitPlayer",
				[16] = "WeldFurnitureToMovingTruck",
				[17] = "StealFurniture",
				[18] = "FurnitureCrushed",
				[19] = "UnhandcuffPlayer",
				[20] = "PutHandcuffsBackOn",
				[21] = "NavigateToPizzaShopConveyor"
			},
			ParkAPI = {
				[1] = "SeesawExitSeat",
				[2] = "SeesawEnterSeat",
				[3] = "RoundaboutSpin",
				[4] = "SeesawEnterPerformanceForOtherClient",
				[5] = "RoundaboutSit",
				[6] = "RequestSeesawEnterPerformanceForOtherClient",
				[7] = "SeesawExitStates",
				[8] = "SeesawExitPlayingSolo",
				[9] = "SeesawEnterPlayingSolo"
			},
			AdoptAPI = {
				[1] = "AcceptDeclineAdopt",
				[2] = "Holding",
				[3] = "BeingHeld",
				[4] = "AdoptionPartyStarted",
				[5] = "HoldBaby",
				[6] = "EjectAllHeldBabies",
				[7] = "UseStroller",
				[8] = "MakeBabyJumpOutOfSeat",
				[9] = "BabySleeped",
				[10] = "MarkEnteredDoorTime",
				[11] = "PassiveDoorEnter",
				[12] = "HoldBabyOnShoulder",
				[13] = "BabyJumped",
				[14] = "SpawnNursery",
				[15] = "FlyPet",
				[16] = "BabyJumpYield",
				[17] = "BabyJump",
				[18] = "RidePet",
				[19] = "MoveBabiesFromHeldToShoulder",
				[20] = "RideParent",
				[21] = "SendPassiveDoorEnter",
				[22] = "EjectBaby"
			},
			ThemedServersAPI = {
				[1] = "GetGroup",
				[2] = "BeginAFKAilments",
				[3] = "SetDiscoveryMethod",
				[4] = "GetPlaceTypesMap",
				[5] = "RequestTeleport",
				[6] = "GetIsParticipating"
			},
			RadioAPI = {
				[1] = "Paused",
				[2] = "Search",
				[3] = "Remove",
				[4] = "Play",
				[5] = "Add",
				[6] = "Pause",
				[7] = "Resume",
				[8] = "NewSoundPlayed"
			},
			ProductImagesAPI = {
				[1] = "SendPrefetchedProductImageIds"
			},
			TeleportAPI = {
				[1] = "TeleportToExperimental",
				[2] = "TeleportToMain"
			},
			ToolAPI = {
				[1] = "CancelGrapplingHook",
				[2] = "FireworkLoaded",
				[3] = "DiscosplosionThrown",
				[4] = "UnequipAll",
				[5] = "FireworkLaunched",
				[6] = "UpdateVotingPaddle",
				[7] = "FireGrapplingHook",
				[8] = "ServerUseTool",
				[9] = "GrapplingHookFired",
				[10] = "LaunchFirework",
				[11] = "Equip",
				[12] = "StickGrapplingHook",
				[13] = "BakeItem",
				[14] = "ScoopIceCream",
				[15] = "CastWaterRaycast",
				[16] = "ModifyItemTopping",
				[17] = "TakeDownToyFurniture",
				[18] = "LoadFirework",
				[19] = "MusicInstrumentPlayed",
				[20] = "PlayMusicInstrument",
				[21] = "PlaceToyFurniture",
				[22] = "ThrowDiscosplosion",
				[23] = "Unequip",
				[24] = "CookMarshmallow"
			},
			ABTestAPI = {
				[1] = "GetFriendshipABGroup"
			},
			UGCAPI = {
				[1] = "RequestRefreshPurchases",
				[2] = "ClaimCollectorReward"
			},
			CloudActionsAPI = {
				[1] = "CloudValuesUpdated",
				[2] = "GetReplicatedCloudValues"
			},
			MonitorAPI = {
				[1] = "AddAdditive",
				[2] = "ShowHealingEffect",
				[3] = "FirstTimeAilmentGPS",
				[4] = "InfectPlayerWithSicknessAilment",
				[5] = "HasAilments",
				[6] = "ClearRate",
				[7] = "HealWithDoctor",
				[8] = "AddRate",
				[9] = "PetAilmentCompleted"
			},
			ShopAPI = {
				[1] = "BuyItem",
				[2] = "IndicateOpenGift",
				[3] = "OpenGift",
				[4] = "ForceWear"
			},
			FriendsAPI = {
				[1] = "FriendAdded",
				[2] = "FriendRemoved"
			},
			LodgeAPI = {
				[1] = "RentLodge",
				[2] = "PlayerKickedFromLodge"
			},
			PetAPI = {
				[1] = "ExchangeMonkeyItems",
				[2] = "ReplicateActiveReactions",
				[3] = "TeleportPetOnClient",
				[4] = "OwnedEggHatched",
				[5] = "ReplicatePerformanceModifiers",
				[6] = "ExchangeRatBox",
				[7] = "BufferPetCommand",
				[8] = "DoNeonFusion",
				[9] = "TogglePetLeash",
				[10] = "FinishPathAnim",
				[11] = "ReplicateActivePerformances",
				[12] = "PetHatched",
				[13] = "ConsumeFoodObject",
				[14] = "ExchangeMonkeyBox",
				[15] = "ReplicateModifiersToClient",
				[16] = "PetProgressed",
				[17] = "ExitFurnitureUseStates",
				[18] = "WipeColoredHairSpray",
				[19] = "UpdatePetTrickLevel",
				[20] = "StartPathAnim",
				[21] = "UnequipPetLeash",
				[22] = "ConsumeFoodItem",
				[23] = "SayPetTrickMessage"
			},
			AdminAPI = {
				[1] = "GetCmdrPlayerInventoryItems",
				[2] = "RequestTradeChatHistory"
			},
			DailyLoginAPI = {
				[1] = "ClaimDailyReward",
				[2] = "ClaimStarReward"
			},
			EffectsAPI = {
				[1] = "DrinkGrowPotion",
				[2] = "DrinkCureAllPotion",
				[3] = "DrinkLevitatePotion",
				[4] = "DrinkHeartPotion",
				[5] = "DrinkWaterWalkingPotion",
				[6] = "DrinkSnowflakePotion",
				[7] = "DrinkBigHeadPotion"
			},
			DataAPI = {
				[1] = "DataChanged",
				[2] = "ServerConstantChanged",
				[3] = "ReplicateInitData",
				[4] = "DataPartiallyChanged",
				[5] = "GetAllServerData",
				[6] = "GetServerLatest"
			},
			EmotesAPI = {
				[1] = "PlayEmote"
			},
			MinigameAPI = {
				[1] = "FinishObby",
				[2] = "AttemptJoin",
				[3] = "WillTeleport",
				[4] = "MessageServer",
				[5] = "MessageClient"
			},
			CodeRedemptionAPI = {
				[1] = "AttemptRedeemCode",
				[2] = "RequestPickColor"
			},
			PromosAPI = {
				[1] = "SubmitCode"
			},
			DebugAPI = {
				[1] = "DebugClient"
			},
			NotificationAPI = {
				[1] = "IndicateEvent"
			},
			SettingsAPI = {
				[1] = "SetSetting",
				[2] = "SetBooleanFlag",
				[3] = "SetPetRoleplayName"
			},
			QuestAPI = {
				[1] = "ClaimQuest",
				[2] = "RerollQuest",
				[3] = "MarkQuestsViewed"
			},
			PlaceableToolAPI = {
				[1] = "DestroyPlaceable",
				[2] = "MagicHouseDoorUsed",
				[3] = "CreatePlaceable",
				[4] = "UseMagicHouseDoor",
				[5] = "BuyRefreshment",
				[6] = "SetRefreshmentPrice",
				[7] = "SetItemForTrade"
			},
			PayAPI = {
				[1] = "CollectEarnings",
				[2] = "PaymentReceived",
				[3] = "CashOut"
			},
			BalloonAPI = {
				[1] = "BuyBalloon",
				[2] = "BungeeJump"
			},
			WeatherAPI = {
				[1] = "WeatherUpdated",
				[2] = "GetSerializedInteriorWeather",
				[3] = "GetWeather",
				[4] = "GetLightingPresets"
			},
			DownloadsAPI = {
				[1] = "Download",
				[2] = "FFC",
				[3] = "GetDisplayModelInfoForItem",
				[4] = "GetNumChildren"
			},
			FeedbackAPI = {
				[1] = "SubmitSurveyResponses",
				[2] = "ShouldShowSurvey",
				[3] = "DeclineSurvey"
			},
			TradeAPI = {
				[1] = "SendCmdrRevertTradeId",
				[2] = "QuizAnswerReported",
				[3] = "SendTradeRequest",
				[4] = "DeclineTrade",
				[5] = "ReactToTrade",
				[6] = "EndQuiz",
				[7] = "RequestCmdrRevertTradeId",
				[8] = "QuickChatReceived",
				[9] = "TradeRequestReceived",
				[10] = "ReportScam",
				[11] = "SendQuickChat",
				[12] = "AddItemToOffer",
				[13] = "AnswerQuizQuestion",
				[14] = "ToggleTyping",
				[15] = "TypingToggled",
				[16] = "RemoveItemFromOffer",
				[17] = "ConfirmTrade",
				[18] = "AcceptOrDeclineTradeRequest",
				[19] = "TogglePickingTradeItem",
				[20] = "AcceptNegotiation",
				[21] = "SpectateTrade",
				[22] = "BeginQuiz",
				[23] = "GiveItem",
				[24] = "GetTradeHistory",
				[25] = "UnacceptNegotiation",
				[26] = "TradeReactedTo"
			},
			FamilyAPI = {
				[1] = "ChangeFamilyName",
				[2] = "AcceptDeclineInvite",
				[3] = "ForceFamilyListUpdate",
				[4] = "FamilyMemberLocationUpdated",
				[5] = "CreateFamily",
				[6] = "GetFamilyMemberLocations",
				[7] = "LeaveFamily",
				[8] = "InvitePlayer"
			},
			AvatarAPI = {
				[1] = "GetRequiredPurchasablesForExportingAvatar",
				[2] = "ResetToRobloxChar",
				[3] = "GetItemDetails",
				[4] = "DeleteOutfit",
				[5] = "SaveOutfit",
				[6] = "UnlockItem",
				[7] = "CharacterAppearanceUpdated",
				[8] = "TakeOffEverything",
				[9] = "BuyMannequinOutfit",
				[10] = "GetItems",
				[11] = "PutOn",
				[12] = "RenameOutfit",
				[13] = "SubmitAvatarAnalyticsEvent",
				[14] = "StartEditingMannequin",
				[15] = "SetGender",
				[16] = "ExportMannequinOutfit",
				[17] = "SearchItems",
				[18] = "SetPlayerOnPlayerCollision",
				[19] = "TakeOff",
				[20] = "WearOutfit",
				[21] = "WearMannequinOutfit"
			},
			LoggingAPI = {
				[1] = "LogLoadTime"
			},
			MsgAPI = {
				[1] = "DialogSent",
				[2] = "RewardNotificationSent",
				[3] = "HintSent",
				[4] = "MsgCreated",
				[5] = "DisplayServerMsg",
				[6] = "GetChatDisabled",
				[7] = "CreateMsg",
				[8] = "SetPlayerMuted",
				[9] = "DownloadInitialQueue",
				[10] = "WatchModeMsg"
			},
			LocationAPI = {
				[1] = "GetLiveOpsMapSwapTransitionCFrame",
				[2] = "FamilyMemberLocationUpdated",
				[3] = "RefreshCharHider",
				[4] = "TeleToPlayer",
				[5] = "GetLocations",
				[6] = "TeleToPlayerInDifferentServer",
				[7] = "GetCharacterRootCFrame",
				[8] = "TeleToLocation",
				[9] = "PlayerTeleportedToPlayer",
				[10] = "GetInteriors",
				[11] = "SetLocation",
				[12] = "GetPlayerCFrame"
			},
			LegacyTutorialAPI = {
				[1] = "EquipTutorialEgg",
				[2] = "AddTutorialQuest",
				[3] = "StashTutorialStatus",
				[4] = "MarkTutorialCompleted",
				[5] = "AddHungryAilmentToTutorialEgg",
				[6] = "SetTutorialInProgressBool"
			},
			InteractablesAPI = {
				[1] = "BabyShouldUseFurniture",
				[2] = "DisableInteractionWithMe",
				[3] = "GetTimeElapsedSinceLastCollectedMoneyTree",
				[4] = "MakeBabyUseFurniture"
			},
			HousingAPI = {
				[1] = "GetModifyHouseAddonsValue",
				[2] = "GetWholeHouseValue",
				[3] = "ChangeTextSignText",
				[4] = "ActivateInteriorFurniture",
				[5] = "SellHouse",
				[6] = "ThrowParty",
				[7] = "PlayerInvitedToParty",
				[8] = "BuyTexture",
				[9] = "GetPlotsSerialized",
				[10] = "UpdateMyHouseProperty",
				[11] = "UnsubscribeFromHouse",
				[12] = "SendHousingOnePointOneLog",
				[13] = "CoopSetLocked",
				[14] = "SellFurniture",
				[15] = "SetDoorLocked",
				[16] = "BuyHouseWithAddons",
				[17] = "BuyFurnitures",
				[18] = "SetRecentlyViewedHouseTemplate",
				[19] = "CoopAddPlayer",
				[20] = "RateParty",
				[21] = "RenameHouse",
				[22] = "SpawnHouse",
				[23] = "CoopRemovePlayer",
				[24] = "CoopRemoveAllPlayers",
				[25] = "ModifyHouseAddons",
				[26] = "PromptRaceStartTeleport",
				[27] = "ActivateFurniture",
				[28] = "PushFurnitureChanges",
				[29] = "ColorHouse",
				[30] = "SubscribeToHouse",
				[31] = "RentPremiumPlot",
				[32] = "AnimatedFurnitureExit",
				[33] = "CoopSetBudget",
				[34] = "ChangeCustomSign"
			},
			GuideArrowAPI = {
				[1] = "GetGraph"
			},
			TutorialAPI = {
				[1] = "SetStarterEggChoice",
				[2] = "GiveAilmentToTutorialPet",
				[3] = "StashCheckpoint",
				[4] = "MarkViewedCutscene",
				[5] = "GetMyTutorialABGroup",
				[6] = "GiveTutorialReward",
				[7] = "StashError",
				[8] = "CompleteExploreNursery",
				[9] = "SetTutorialStage",
				[10] = "GiveBucksReward",
				[11] = "SetTutorialInProgress"
			}
		}
		
		local RemotesNames = {}
		for categoryName, category in pairs(API_Dump) do
			for _, remoteName in pairs(category) do
				table.insert(RemotesNames, "\""..categoryName.."/"..remoteName.."\"")
			end
		end
		
		_G.LoadLocalCode([[local Fsys = require(game:GetService("ReplicatedStorage"):WaitForChild("Fsys"))
local RouterClient = Fsys.load("RouterClient")
local RemotesList = {]] .. table.concat(RemotesNames, ",") .. [[}

local i, total = 0, 0
local remote
for _,remoteName in pairs(RemotesList) do
	total += 1
	remote = RouterClient.get(remoteName)
	if remote then
		i += 1
		remote.Name = remoteName
	end
end
print("Decrypted", i, "remotes out of", total)]], "10df0ekte0")
		
		local env = getfenv(module.Init)
		for categoryName,category in pairs(API_Dump) do
			for _,remoteName in pairs(category) do
				if not env[categoryName] then
					env[categoryName] = {}
				end
				env[categoryName][remoteName] = API:FindFirstChild(categoryName.."/"..remoteName)
			end
		end
		API_Dump = nil -- force-garbage collect for performance
	end
end

return module