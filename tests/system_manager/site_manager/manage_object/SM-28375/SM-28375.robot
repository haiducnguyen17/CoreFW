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
Library    ../../../../../py_sources/logigear/page_objects/system_manager/administration/spaces/AdmLayerImageFilesPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/upgrade_to_ipatch/UpgradeToiPatchPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/tools/database_tools/RestoreDatabasePage${PLATFORM}.py   

Default Tags    Manage Object
Force Tags    SM-28375 

*** Variables ***
${FLOOR_NAME}    Floor 01 
${ROOM_NAME}    Room 01
${CABLE_VAULT}    Cable Vault 01
${SPLICE_ENCLOSURE}    Splice_Enclosure
${ROOM_WITH_YELLOW_ICON}    RoomEquipmentSmall
${ROOM_WITH_WHITE_ICON}    RoomSmall
${CV_WITH_YELLOW_ICON}    CableVaultEquipmentSmall
${CV_WITH_WHITE_ICON}    CableVaultSmall

*** Test Cases ***
Bulk1 (SM-28375_01->04) Verify Room & CV Icons Are Changed After Adding/Deleting, Cutting/Pasting, Copying/Pasting and Dragging/ Dropping Splice Enclosure
   
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    Building_SM28375_01    
    ...    AND    Set Test Variable    ${cablevault_name}    CV_SM28375_01
    ...    AND    Set Test Variable    ${cablevault_name_2}    CV_SM28375_02_2
    ...    AND    Delete Building    name=${building_name}  
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Delete Tree Node If Exist On Site Manager     ${SITE_NODE}/${cablevault_name}
    ...    AND    Delete Tree Node If Exist On Site Manager     ${SITE_NODE}/${cablevault_name_2}
    ...    AND    Add New Building    ${building_name}
    ...    AND    Reload Page
  
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Delete Tree Node On Site Manager     ${SITE_NODE}/${cablevault_name}
    ...    AND    Delete Tree Node On Site Manager     ${SITE_NODE}/${cablevault_name_2}
    ...    AND    Close Browser

    ${room_name_2} =     Set Variable    Room 02

    [Tags]    Sanity
   
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}
    Check Icon Object On Site Tree        ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${ROOM_WITH_WHITE_ICON}
    Add Splice Enclosure    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${room_name}    ${SPLICE_ENCLOSURE}
    
    #The Room icon is changed to yellow
    Check Icon Object On Site Tree    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${ROOM_WITH_YELLOW_ICON}
    
    Add Cable Vault    ${SITE_NODE}    ${cablevault_name}
    Check Icon Object On Site Tree    ${SITE_NODE}/${cablevault_name}    ${CV_WITH_WHITE_ICON}
    Add Splice Enclosure    ${SITE_NODE}/${cablevault_name}    ${SPLICE_ENCLOSURE}
    
    #The CV icon is changed to yellow
    Check Icon Object On Site Tree        ${SITE_NODE}/${cablevault_name}    ${CV_WITH_YELLOW_ICON} 

    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${room_name_2}
   
    Add Cable Vault    ${SITE_NODE}    ${cablevault_name_2}
        
    #Cut Splice Enclosure 01 from Room 01 to Room  02
    Cut And Paste Object On Site Tree    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE}
    ...    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${room_name_2}
    
    #Cut Splice Enclosure 01 from CV 01 to CV  02
    Cut And Paste Object On Site Tree    ${SITE_NODE}/${cablevault_name}/${SPLICE_ENCLOSURE}
    ...    ${SITE_NODE}/${cablevault_name_2}
    
    Check Icon Object On Site Tree        ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${ROOM_WITH_WHITE_ICON}
    Check Icon Object On Site Tree        ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${room_name_2}    ${ROOM_WITH_YELLOW_ICON}
    
    Check Icon Object On Site Tree        ${SITE_NODE}/${cablevault_name}    ${CV_WITH_WHITE_ICON}
    Check Icon Object On Site Tree        ${SITE_NODE}/${cablevault_name_2}    ${CV_WITH_YELLOW_ICON}
   
    #Drag and grop Splice Enclosure from Room 2 to Room 1 and from CV 2 to CV 1
    Drag And Drop Object On Site Tree    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${room_name_2}/${SPLICE_ENCLOSURE}    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}   
    Drag And Drop Object On Site Tree    ${SITE_NODE}/${cablevault_name_2}/${SPLICE_ENCLOSURE}    ${SITE_NODE}/${cablevault_name}

    Check Icon Object On Site Tree        ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${room_name_2}    ${ROOM_WITH_WHITE_ICON}
    Check Icon Object On Site Tree        ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${ROOM_WITH_YELLOW_ICON}
    
    Check Icon Object On Site Tree        ${SITE_NODE}/${cablevault_name_2}    ${CV_WITH_WHITE_ICON}
    Check Icon Object On Site Tree        ${SITE_NODE}/${cablevault_name}    ${CV_WITH_YELLOW_ICON}
    
    #Copy Splice Enclosure 01 from Room 01 to Room  02
    Copy And Paste Object On Site Tree    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE}
    ...    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${room_name_2}
    
    #Copy Splice Enclosure 01 from CV 01 to CV  02
    Copy And Paste Object On Site Tree    ${SITE_NODE}/${cablevault_name}/${SPLICE_ENCLOSURE}
    ...    ${SITE_NODE}/${cablevault_name_2}
    
    #The Room icon is changed to yellow
    Check Icon Object On Site Tree        ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${ROOM_WITH_YELLOW_ICON}
    Check Icon Object On Site Tree        ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${room_name_2}    ${ROOM_WITH_YELLOW_ICON}
    
    #The CV icon is changed to yellow
    Check Icon Object On Site Tree        ${SITE_NODE}/${cablevault_name}    ${CV_WITH_YELLOW_ICON}
    Check Icon Object On Site Tree        ${SITE_NODE}/${cablevault_name_2}    ${CV_WITH_YELLOW_ICON}
    
    #The Room icon is changed to white
    Delete Tree Node On Site Manager    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}/${SPLICE_ENCLOSURE}
    Check Icon Object On Site Tree        ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${ROOM_WITH_WHITE_ICON}
    
    #The CV icon is changed to white
    Delete Tree Node On Site Manager    ${SITE_NODE}/${cablevault_name}/${SPLICE_ENCLOSURE}
    Check Icon Object On Site Tree        ${SITE_NODE}/${cablevault_name}    ${CV_WITH_WHITE_ICON}
    
SM-28375-05_Verify That The Room And CV Icons With Splice Enclosure Are Displayed Correctly In The Windows
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    Building_SM28375_05
    ...    AND    Set Test Variable    ${cable_vault_name_1}    CV_SM28375_05_01
    ...    AND    Set Test Variable    ${cable_vault_name_2}    CV_SM28375_05_02
    ...    AND    Set Test Variable    ${cable_vault_name_3}    CV_SM28375_05_03
    ...    AND    Delete Building    name=${building_name}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${cable_vault_name_1}
    ...    AND    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${cable_vault_name_2}
    ...    AND    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${cable_vault_name_3}
    ...    AND    Add New Building    ${building_name}    
    ...    AND    Reload Page
        
    [Teardown]    Run Keywords    Delete Building    name=${building_name}
    ...    AND    Delete Tree Node On Site Manager    ${SITE_NODE}/${cable_vault_name_1}
    ...    AND    Delete Tree Node On Site Manager    ${SITE_NODE}/${cable_vault_name_2}
    ...    AND    Delete Tree Node On Site Manager    ${SITE_NODE}/${cable_vault_name_3}
    ...    AND    Close Browser
    
    ${city_name} =    Set Variable    City_SM28375_05
    ${campus_name} =    Set Variable    Campus_SM28375_05
    ${floor_name} =    Set Variable    Floor 01
    ${room_name_1} =    Set Variable    Room 01
    ${room_name_2} =    Set Variable    Room 02
    ${cubicle_name_1} =     Set Variable    Cubicle 01
    ${cubicle_name_2} =     Set Variable    Cubicle 02
    ${se_name_1} =    Set Variable    Splice Enclosure 01
    ${se_name_2} =    Set Variable    Splice Enclosure 02    
    ${rack_name} =    Set Variable    Rack 001
    ${switch_name_01} =    Set Variable    Switch 01   
    ${port_name_01} =    Set Variable    01

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
    Add Floor    ${SITE_NODE}/${building_name}    ${floor_name}
    Add Room    ${SITE_NODE}/${building_name}/${floor_name}    ${room_name_1} 
    Add Splice Enclosure    ${SITE_NODE}/${building_name}/${floor_name}/${room_name_1}    ${se_name_1}     
    Add Cubicle    ${SITE_NODE}/${building_name}/${floor_name}    ${cubicle_name_1}
    Add Cable Vault    ${SITE_NODE}    ${cable_vault_name_1}
    Add Splice Enclosure    ${SITE_NODE}/${cable_vault_name_1}    ${se_name_2}
    Add Room    ${SITE_NODE}/${building_name}/${floor_name}    ${room_name_2}
    Add Cable Vault    ${SITE_NODE}    ${cable_vault_name_2}
    Add Cable Vault    ${SITE_NODE}    ${cable_vault_name_3}
    Add Rack    ${SITE_NODE}/${cable_vault_name_3}    ${rack_name} 
    Add Network Equipment    ${SITE_NODE}/${cable_vault_name_3}/1:1 ${rack_name}    ${switch_name_01}
    Add Network Equipment Port    ${SITE_NODE}/${cable_vault_name_3}/1:1 ${rack_name}/${switch_name_01}    ${port_name_01}
    
    # 5. Open the Patching/Cabling/DEP/Circuit Provisioning/Conduits/... window  
    # 6. Observe the Room and Cable Vault icons in the window 
    # VP: The Room 01 and Cable Vault 01 icons are in yellow.
    # VP: The Room 02 and Cable Vault 02 icons are in yellow.
    # 7. Close the window
    
    Open Define Equipment Patches Window    ${SITE_NODE}/${cable_vault_name_3}/1:1 ${rack_name}         
    Check Icon Object On Define Equipment Patches Tree    From    ${SITE_NODE}/${cable_vault_name_3}    ${CV_WITH_YELLOW_ICON} 
    Check Icon Object On Define Equipment Patches Tree    To    ${SITE_NODE}/${cable_vault_name_3}    ${CV_WITH_YELLOW_ICON} 
    Close Define Equipment Patches Window    
    
    Open Circuit Provisioning Window     ${SITE_NODE}/${cable_vault_name_3}/1:1 ${rack_name}/${switch_name_01}    ${port_name_01}
    Check Icon Object On Circuit Provisioning Tree    From    ${cable_vault_name_3}    ${CV_WITH_YELLOW_ICON} 
    Check Icon Object On Circuit Provisioning Tree    To    ${SITE_NODE}/${cable_vault_name_3}    ${CV_WITH_YELLOW_ICON}
    Check Icon Object On Circuit Provisioning Tree    To    ${SITE_NODE}/${cable_vault_name_1}    ${CV_WITH_YELLOW_ICON}
    Check Icon Object On Circuit Provisioning Tree    To    ${SITE_NODE}/${cable_vault_name_2}    ${CV_WITH_WHITE_ICON}
    Check Icon Object On Circuit Provisioning Tree    To    ${SITE_NODE}/${building_name}/${floor_name}/${room_name_1}    ${ROOM_WITH_YELLOW_ICON}
    Check Icon Object On Circuit Provisioning Tree    To    ${SITE_NODE}/${building_name}/${floor_name}/${room_name_2}    ${ROOM_WITH_WHITE_ICON}
    Close Circuit Provisioning Window 
    
    # 8. Delete Splice Enclosure 01-02
    # 9. Open the Patching/Cabling/Circuit Provisioning/Conduits/... window
    Delete Tree Node On Site Manager    ${SITE_NODE}/${building_name}/${floor_name}/${room_name_1}/${se_name_1}
    Delete Tree Node On Site Manager    ${SITE_NODE}/${cable_vault_name_1}/${se_name_2}
    
    Open Circuit Provisioning Window     ${SITE_NODE}/${cable_vault_name_3}/1:1 ${rack_name}/${switch_name_01}    ${port_name_01}
    Check Icon Object On Circuit Provisioning Tree    To    ${SITE_NODE}/${cable_vault_name_1}    ${CV_WITH_WHITE_ICON}
    Check Icon Object On Circuit Provisioning Tree    To    ${SITE_NODE}/${building_name}/${floor_name}/${room_name_1}    ${ROOM_WITH_WHITE_ICON}
    Close Circuit Provisioning Window
    
SM-28375_06_Verify That The Room And CV Icons Are Changed After Adding/Deleting Splice Enclosure In The Spaces View
    [Setup]    Run Keywords    Set Test Variable    ${building_name_1}    Building_SM28375_05
    ...    AND    Set Test Variable    ${city_name_1}    City_SM28375_05
    ...    AND    Delete Building    name=${building_name_1}
    ...    AND    Add New Building    ${building_name_1}
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Delete Tree Node If Exist On Site Manager    ${SITE_NODE}/${city_name_1}
    
    [Teardown]    Run Keywords    Select Main Menu    ${Site Manager}
    ...    AND    Delete Building    name=${building_name_1}
    ...    AND    Delete Tree Node On Site Manager    ${SITE_NODE}/${city_name_1}
    ...    AND    Select Main Menu    ${Administration}/${Spaces}    ${Layer Image Files}
    ...    AND    Close Browser
    
    ${building_name_1} =    Set Variable    Building_SM28375_05
    ${room_name_2} =    Set Variable    Room 02
    ${city_name_1} =    Set Variable    City_SM28375_05
    ${se_name_1} =    Set Variable    Splice Enclosure 01
    ${se_name_2} =    Set Variable    Splice Enclosure 02
    ${image_name} =    Set Variable    Layer_SM28375_05    
    ${image_location} =    Set Variable    C:\\Pre Condition\\Layers\\logigear_building.jpg
    ${position_destination} =    Set Variable    10,10
    
    Select Main Menu    ${Administration}/${Spaces}    ${Layer Image Files}
    Add Layer Image Files    ${image_name}    ${image_location}
    
    Select Main Menu    ${Site Manager}

    Add Floor    ${SITE_NODE}/${building_name_1}    ${FLOOR_NAME}
    Add Room    ${SITE_NODE}/${building_name_1}/${FLOOR_NAME}    ${ROOM_NAME}
    
    Add City    ${SITE_NODE}    ${city_name_1}
    Add Cable Vault    ${SITE_NODE}/${city_name_1}    ${CABLE_VAULT}
    
    Go To Another View On Site Manager    Spaces
    Assign Layer Image To Object    ${SITE_NODE}/${building_name_1}/${FLOOR_NAME}    ${image_name}        
    Place Object On Space    ${SITE_NODE}/${building_name_1}/${FLOOR_NAME}    ${SITE_NODE}/${building_name_1}/${FLOOR_NAME}/${ROOM_NAME}    ${position_destination}
    Assign Layer Image To Object    ${SITE_NODE}/${city_name_1}    ${image_name}
    Place Object On Space    ${SITE_NODE}/${city_name_1}    ${SITE_NODE}/${city_name_1}/${CABLE_VAULT}    ${position_destination}        
    
    Add Splice Enclosure    ${SITE_NODE}/${building_name_1}/${FLOOR_NAME}/${ROOM_NAME}    ${se_name_1}    waitForExist=False
    Add Splice Enclosure    ${SITE_NODE}/${city_name_1}/${CABLE_VAULT}    ${se_name_2}    waitForExist=False
    
    Check Icon Object On Site Tree        ${SITE_NODE}/${building_name_1}/${FLOOR_NAME}/${ROOM_NAME}    ${ROOM_WITH_YELLOW_ICON}
    Check Icon Object On Site Tree        ${SITE_NODE}/${city_name_1}/${CABLE_VAULT}    ${CV_WITH_YELLOW_ICON}
    
    Delete Tree Node On Site Manager    ${SITE_NODE}/${building_name_1}/${FLOOR_NAME}/${ROOM_NAME}/${se_name_1}
    Delete Tree Node On Site Manager    ${SITE_NODE}/${city_name_1}/${CABLE_VAULT}/${se_name_2}
    
    Check Icon Object On Site Tree        ${SITE_NODE}/${building_name_1}/${FLOOR_NAME}/${ROOM_NAME}    ${ROOM_WITH_WHITE_ICON}
    Check Icon Object On Site Tree        ${SITE_NODE}/${city_name_1}/${CABLE_VAULT}    ${CV_WITH_WHITE_ICON}
    
SM-28375_08_Verify That The Room And Cv Icons Are Updated After Converting Db   
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Delete Tree Node On Site Manager     ${SITE_NODE}/${cablevault_name_1}
    ...    AND    Delete Tree Node On Site Manager    ${SITE_NODE}/${cablevault_name_2}
    ...    AND    Close Browser
    
    ${building_name} =    Set Variable    BD_SM28375_08
    ${cablevault_name_1} =    Set Variable    CV_SM28375_08_1
    ${cablevault_name_2} =    Set Variable    CV_SM28375_08_2
    ${room_name_2} =    Set Variable    Room 02
    ${file_bk} =    Set Variable    SM-28375-TC08.bak

    Open SM Login Page
    Login To SM    ${USERNAME}    ${PASSWORD}
    Restore Database    ${file_bk}    ${DIR_FILE_BK}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Check Icon Object On Site Tree        ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME}    ${ROOM_WITH_YELLOW_ICON}
    Check Icon Object On Site Tree        ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${room_name_2}    ${ROOM_WITH_WHITE_ICON}
    Check Icon Object On Site Tree        ${SITE_NODE}/${cablevault_name_1}    ${CV_WITH_YELLOW_ICON}
    Check Icon Object On Site Tree        ${SITE_NODE}/${cablevault_name_2}    ${CV_WITH_WHITE_ICON}
    
        
SM-28375_09_Verify That The Room And CV Icons Are Updated In The Spaces View After Converting DB   
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Delete Tree Node On Site Manager    ${SITE_NODE}/${city_name}
    ...    AND    Close Browser
   
    ${building_name} =    Set Variable    BD_SM28375_09
    ${cablevault_name_1} =    Set Variable    CV_SM28375_09_1
    ${cablevault_name_2} =    Set Variable    CV_SM28375_09_2
    ${room_name_2} =    Set Variable    Room 02
    ${city_name} =    Set Variable    City 01
    ${file_bk} =    Set Variable    SM-28375-TC09.bak
    
    Open SM Login Page
    Login To SM    ${USERNAME}    ${PASSWORD}
    Restore Database    ${file_bk}    ${DIR_FILE_BK}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Go To Another View On Site Manager    Spaces
    Check Icon Object On Spaces tab    ${SITE_NODE}/${city_name}    ${cablevault_name_1}    ${CV_WITH_YELLOW_ICON}        
    Check Icon Object On Spaces tab    ${SITE_NODE}/${city_name}    ${cablevault_name_2}    ${CV_WITH_WHITE_ICON}        
    Check Icon Object On Spaces tab    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME}    ${ROOM_WITH_YELLOW_ICON}  
    Check Icon Object On Spaces tab    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${room_name_2}    ${ROOM_WITH_WHITE_ICON}
    