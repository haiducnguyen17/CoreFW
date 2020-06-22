*** Settings ***
Resource    ../../../../../resources/constants.robot

Library   ../../../../../py_sources/logigear/setup.py
Library   ../../../../../py_sources/logigear/api/BuildingApi.py    ${USERNAME}    ${PASSWORD}
Library   ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py    
Library   ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/front_to_back_cabling/FrontToBackCablingPage${PLATFORM}.py            
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/conduits/ConduitsPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/osp_cabling/OspCablingPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/define_equipment_patches/DefineEquipmentPatchesPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/circuit_provisioning/CircuitProvisioningPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/replace_network_equipment/ReplaceNetworkEquipmentPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/upgrade_to_ipatch/UpgradeToiPatchPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/tools/database_tools/RestoreDatabasePage${PLATFORM}.py            
Library    ../../../../../py_sources/logigear/page_objects/system_manager/administration/AdministrationPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py
Library    DataDriver	file=../../../../../test-data/sm-28375/CheckObjectIcon-Delete.xls    sheet_name=DataDriven

Test Template     Check Icon on Connections windows after add object

Default Tags    Manage Object
Force Tags    SM-28375 

Suite Setup    Run Keywords    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${cable_vault_name_1}
    ...    AND    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${cable_vault_name_2}
    ...    AND    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${cable_vault_name_3}
    ...    AND    Add New Building    ${building_name}
    ...    AND    Reload Page
    ...    AND    Add Floor    ${SITE_NODE}/${building_name}    ${floor_name}
    ...    AND    Add Room    ${SITE_NODE}/${building_name}/${floor_name}    ${room_name_1} 
    ...    AND    Add Splice Enclosure    ${SITE_NODE}/${building_name}/${floor_name}/${room_name_1}    ${se_name_1}  
    ...    AND    Add Cubicle    ${SITE_NODE}/${building_name}/${floor_name}    ${cubicle_name_1}
    ...    AND    Add Cable Vault    ${SITE_NODE}    ${cable_vault_name_1}
    ...    AND    Add Splice Enclosure    ${SITE_NODE}/${cable_vault_name_1}    ${se_name_2}
    ...    AND    Add Room    ${SITE_NODE}/${building_name}/${floor_name}    ${room_name_2}
    ...    AND    Add Cable Vault    ${SITE_NODE}    ${cable_vault_name_2}
    ...    AND    Add Cable Vault    ${SITE_NODE}    ${cable_vault_name_3}
    ...    AND    Add Rack    ${SITE_NODE}/${cable_vault_name_3}    ${rack_name} 
    ...    AND    Add Network Equipment    ${SITE_NODE}/${cable_vault_name_3}/1:1 ${rack_name}    ${switch_name_01}
    ...    AND    Add Network Equipment Port    ${SITE_NODE}/${cable_vault_name_3}/1:1 ${rack_name}/${switch_name_01}    ${port_name_01}
    ...    AND    Delete Tree Node On Site Manager    ${SITE_NODE}/${building_name}/${floor_name}/${room_name_1}/${se_name_1}
    ...    AND    Delete Tree Node On Site Manager    ${SITE_NODE}/${cable_vault_name_1}/${se_name_2}

Suite Teardown    Run Keywords    Delete Building    name=${building_name}
    ...    AND    Delete Tree Node On Site Manager    ${SITE_NODE}/${cable_vault_name_1}
    ...    AND    Delete Tree Node On Site Manager    ${SITE_NODE}/${cable_vault_name_2}
    ...    AND    Delete Tree Node On Site Manager    ${SITE_NODE}/${cable_vault_name_3}
    ...    AND    Close Browser

*** Variables ***
${ROOM_WITH_YELLOW_ICON}    RoomEquipmentSmall
${ROOM_WITH_WHITE_ICON}    RoomSmall
${CV_WITH_YELLOW_ICON}    CableVaultEquipmentSmall
${CV_WITH_WHITE_ICON}    CableVaultSmall
${building_name} =    Building_SM28375_05
${city_name} =    City_SM28375_05
${campus_name} =    Campus_SM28375_05
${floor_name} =    Floor 01
${room_name_1} =    Room 01
${room_name_2} =    Room 02
${cubicle_name_1} =     Cubicle 01
${cubicle_name_2} =     Cubicle 02
${cable_vault_name_1} =    CV_SM28375_05_01
${cable_vault_name_2} =    CV_SM28375_05_02
${cable_vault_name_3} =    CV_SM28375_05_03
${se_name_1} =    Splice Enclosure 01
${se_name_2} =    Splice Enclosure 02    
${rack_name} =    Rack 001
${switch_name_01} =    Switch 01   
${port_name_01} =    01

*** Test Cases *** 
SM-28375-05 Check icon in tree ${tree} with node ${treenode} and expectation ${icon}    UserData    UserData    UserData
    # 1. Launch and log into SM Web
    # 2. Go to "Site Manager" page
    # 3. Add: 
    # _Room 01 (or Cubicle 01)/ Splice Enclosure 01 to Building 01/ Floor 01. Notice the Room icon is in yellow
    # _Cable Vault 01/ Splice Enclosure 02 to Site or City or Campus. Notice the Cable Vault icon is in yellow
    # _Cable Vault 03
    # _Rack 001/ Switch 01 with some ports to Cable Vault 03
    # 4. Add: 
    # _Room 02 (or Cubicle 02) to Building 01/ Floor 01
    # _Cable Vault 02 to Site or City or Campus
    
*** Keywords ***
Check Icon on Connections windows after add object
	[Arguments]    ${tree}     ${treenode}    ${icon}
	
    Open Patching Window    ${SITE_NODE}/${building_name}/${floor_name}/${room_name_1}
    Check Icon Object On Patching Tree    ${tree}     ${treenode}    ${icon}
    Close Patching Window
    
    Open Cabling Window    ${SITE_NODE}/${building_name}/${floor_name}/${room_name_1}
    Check Icon Object On Cabling Tree    ${tree}     ${treenode}    ${icon}
    Close Cabling Window

    Open Front To Back Cabling Window    ${SITE_NODE}/${building_name}/${floor_name}/${room_name_1}
    Check Icon Object On Front To Back Cabling Tree    ${tree}     ${treenode}    ${icon}
    Close Front To Back Cabling Window

    Open OSP Cabling Window    ${SITE_NODE}/${building_name}/${floor_name}/${room_name_1}
    Check Icon Object On Osp Cabling Tree    ${tree}     ${treenode}    ${icon}
    Close Front To Back Cabling Window
    
    Open Conduits Window    ${SITE_NODE}/${building_name}/${floor_name}/${room_name_1}   
    Click Add Conduits Button
    Check Icon Object On Conduits Tree    ${tree}     ${treenode}    ${icon}
    Close Add Conduits Window
    Close Manage Conduits Window
    