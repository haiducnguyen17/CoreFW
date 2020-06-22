*** Settings ***
Resource    ../../../../../resources/constants.robot

Library   ../../../../../py_sources/logigear/setup.py  
Library   ../../../../../py_sources/logigear/api/BuildingApi.py    ${USERNAME}    ${PASSWORD}          
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py    
Library    ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/administration/AdministrationPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/upgrade_to_ipatch/UpgradeToiPatchPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/tools/database_tools/RestoreDatabasePage${PLATFORM}.py   
Library    ../../../../../py_sources/logigear/page_objects/system_manager/administration/list/AdmListPage${PLATFORM}.py

Suite Setup    Run Keywords   Delete Building     name=${BUILDING_NAME_1}
    ...    AND    Delete Building     name=${BUILDING_NAME_2} 
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Remove File    ${LOC_RACVIEWIMG_2}
    ...    AND    Remove File    ${LOC_RACVIEWIMG_3}
    ...    AND    Remove File    ${LOC_RACVIEWIMG_4}
    ...    AND    Delete Tree Node If Exist On Site Manager     ${SITE_NODE}/${CABLE_VAULT_NAME}
    ...    AND    Select Main Menu    ${Administration}    Lists
    ...    AND    Add List On Administration    ${LIST_TYPE}    ${ENCLOSURE_2U}    ${DIR_ENCLOSURE_2U}
    ...    AND    Add List On Administration    ${LIST_TYPE}    ${ENCLOSURE_3U}    ${DIR_ENCLOSURE_3U}
    ...    AND    Add List On Administration    ${LIST_TYPE}    ${ENCLOSURE_4U}    ${DIR_ENCLOSURE_4U}

Suite Teardown    Run Keywords    Select Main Menu    ${Site Manager}   
    ...    AND    Delete Object On Content Table    ${SITE_NODE}
    ...    AND    Select Main Menu    ${Administration}    Lists
    ...    AND    Delete List On Administration    ${LIST_TYPE}    ${ENCLOSURE_2U}
    ...    AND    Delete List On Administration    ${LIST_TYPE}    ${ENCLOSURE_3U}
    ...    AND    Delete List On Administration    ${LIST_TYPE}    ${ENCLOSURE_4U}
    ...    AND    Remove File    ${LOC_RACVIEWIMG_2}
    ...    AND    Remove File    ${LOC_RACVIEWIMG_3}
    ...    AND    Remove File    ${LOC_RACVIEWIMG_4}
    ...    AND    Close Browser

Default Tags    Manage Object
Force Tags    SM-29729  

*** Variables ***
${BUILDING_NAME_1}    BD_SM29729_02
${BUILDING_NAME_2}    BD_SM29729_03
${CABLE_VAULT_NAME}    CV_SM29729_01
${BUILDING_9.1}    TM_BLE_020
${FLOOR_NAME}    Floor 01 
${ROOM_NAME}    Room 01
${RACK_NAME}    Rack 001
${RACK_NAME_2}    Rack 004
${CABINET_NAME}    Cabinet 001
${AUXILIARY_NAME}    Auxiliary 001
${SPLICE_ENCLOSURE_1}    Splice_Enclosure_01
${SPLICE_ENCLOSURE_2}    Splice_Enclosure_02
${SPLICE_ENCLOSURE_3}    Splice_Enclosure_03
${SPLICE_ENCLOSURE_4}    Splice_Enclosure_04
${ENCLOSURE_1U_FILENAME}    SpliceEnclosureInRack_1U.png
${ENCLOSURE_2U_FILENAME}    EnclosureInRack_2U.png
${ENCLOSURE_3U_FILENAME}    EnclosureInRack_3U.png
${ENCLOSURE_4U_FILENAME}    EnclosureInRack_4U.png
${DIR_ENCLOSURE_1U}    ${DIR_PRECONDITION_PICTURE}\\${ENCLOSURE_1U_FILENAME}
${DIR_ENCLOSURE_2U}    ${DIR_PRECONDITION_PICTURE}\\${ENCLOSURE_2U_FILENAME}
${DIR_ENCLOSURE_3U}    ${DIR_PRECONDITION_PICTURE}\\${ENCLOSURE_3U_FILENAME}
${DIR_ENCLOSURE_4U}    ${DIR_PRECONDITION_PICTURE}\\${ENCLOSURE_4U_FILENAME}
${LOC_RACVIEWIMG_1}    ${DIR_RACKVIEWIMG_COMMSCOPE}\\${ENCLOSURE_1U_FILENAME}
${LOC_RACVIEWIMG_2}    ${DIR_RACKVIEWIMG_COMMSCOPE}\\${ENCLOSURE_2U_FILENAME}
${LOC_RACVIEWIMG_3}    ${DIR_RACKVIEWIMG_COMMSCOPE}\\${ENCLOSURE_3U_FILENAME}
${LOC_RACVIEWIMG_4}    ${DIR_RACKVIEWIMG_COMMSCOPE}\\${ENCLOSURE_4U_FILENAME}
${ENCLOSURE_1U}    Splice Enclosure In Rack
${ENCLOSURE_2U}    Enclosure 2U
${ENCLOSURE_3U}    Enclosure 3U
${ENCLOSURE_4U}    Enclosure 4U
${RACK_VIEW_FRONT}    Rack View (Front)
${RACK_VIEW_ZEROU}    Rack View (Zero U)
${Auxiliary Rack}    Auxiliary Rack
${Cabinet (42U)}    Cabinet (42U)
${LIST_TYPE}    Equipment Images

*** Test Cases ***
(Bulk SM-29729_01-02) Verify that new image can show correctly when add Splice Enclosure to Rack/Cabinets/Auxiliary Racks under Cable Vault and Building
   
    [Tags]    Sanity

    ${tree_node_room}    Set Variable    ${SITE_NODE}/${BUILDING_NAME_1}/${FLOOR_NAME}/${ROOM_NAME}
    
    # 1. Launch and log into SM
    # 2. Add Rack 01, Cabinet 02, Auxiliary Rack 03 to Cable Vault 01, Building 01/Floor 01/Room 01
    # 3. Add Splice Enclosure 01 to Rack 01, Cabinet 02, Auxiliary Rack 03 
    Select Main Menu    ${Site Manager}
    Create Object    ${SITE_NODE}    ${BUILDING_NAME_1}    ${FLOOR_NAME}    ${ROOM_NAME}
    ${tree_node_cable_vault} =    Add Cable Vault    ${SITE_NODE}    ${CABLE_VAULT_NAME}    
    ${tree_node_rack_bd} =     Add Rack    ${tree_node_room}    ${RACK_NAME}    position=1
    ${tree_node_cabinet_bd} =    Add Rack    ${tree_node_room}    ${CABINET_NAME}    rackType=${Cabinet (42U)}    position=2
    ${tree_node_auxiliary_bd} =    Add Rack    ${tree_node_room}    ${AUXILIARY_NAME}    rackType=${Auxiliary Rack}    position=3    capacityU=42
    ${tree_node_rack_cv} =     Add Rack    ${tree_node_cable_vault}    ${RACK_NAME}    position=1
    ${tree_node_cabinet_cv} =    Add Rack    ${tree_node_cable_vault}    ${CABINET_NAME}    rackType=${Cabinet (42U)}    position=2
    ${tree_node_auxiliary_cv} =    Add Rack    ${tree_node_cable_vault}    ${AUXILIARY_NAME}    rackType=${Auxiliary Rack}    position=3    capacityU=42
        
    ${tree_node_contain_object}    Create List    ${tree_node_rack_bd}    ${tree_node_cabinet_bd}    ${tree_node_auxiliary_bd}    ${tree_node_rack_cv}    ${tree_node_cabinet_cv}    ${tree_node_auxiliary_cv}
    ${splice_enclosure_images_1}    Create List    ${ENCLOSURE_1U_FILENAME}    ${ENCLOSURE_2U_FILENAME}    ${ENCLOSURE_3U_FILENAME}    ${ENCLOSURE_1U_FILENAME}    ${ENCLOSURE_2U_FILENAME}    ${ENCLOSURE_3U_FILENAME}
    ${splice_enclosure_images_2}    Create List    ${ENCLOSURE_2U_FILENAME}    ${ENCLOSURE_3U_FILENAME}    ${ENCLOSURE_4U_FILENAME}    ${ENCLOSURE_2U_FILENAME}    ${ENCLOSURE_3U_FILENAME}    ${ENCLOSURE_4U_FILENAME}
    ${splice_enclosure_names}    Create List    ${SPLICE_ENCLOSURE_1}    ${SPLICE_ENCLOSURE_2}    ${SPLICE_ENCLOSURE_3}    ${SPLICE_ENCLOSURE_1}    ${SPLICE_ENCLOSURE_2}    ${SPLICE_ENCLOSURE_3}
    ${equipment_image_name_1}    Create List    None    ${ENCLOSURE_2U}    ${ENCLOSURE_3U}    None    ${ENCLOSURE_2U}    ${ENCLOSURE_3U}
    ${equipment_image_name_2}    Create List    ${ENCLOSURE_2U}    ${ENCLOSURE_3U}    ${ENCLOSURE_4U}    ${ENCLOSURE_2U}    ${ENCLOSURE_3U}    ${ENCLOSURE_4U}
    ${equipment_image_name_3}    Create List    ${ENCLOSURE_1U}    ${ENCLOSURE_2U}    ${ENCLOSURE_3U}    ${ENCLOSURE_1U}    ${ENCLOSURE_2U}    ${ENCLOSURE_3U}
    ${location_img_name_1}    Create List    ${LOC_RACVIEWIMG_1}    ${LOC_RACVIEWIMG_2}    ${LOC_RACVIEWIMG_3}    ${LOC_RACVIEWIMG_1}    ${LOC_RACVIEWIMG_2}    ${LOC_RACVIEWIMG_3}
    ${location_img_name_2}    Create List    ${DIR_ENCLOSURE_1U}    ${DIR_ENCLOSURE_2U}    ${DIR_ENCLOSURE_3U}    ${DIR_ENCLOSURE_1U}    ${DIR_ENCLOSURE_2U}    ${DIR_ENCLOSURE_3U}
    
    # 4. Observe Rack view on Add Dialog
    :FOR    ${i}    IN RANGE    0    len(${tree_node_contain_object})
    \    Add Splice Enclosure    ${tree_node_contain_object}[${i}]    ${splice_enclosure_names}[${i}]    equipmentImageName=${equipment_image_name_1}[${i}]    confirmSave=${False}    waitForExist=${False}
    \    Check Equipment Image Exist On Properties Window    ${splice_enclosure_images_1}[${i}]
    \    Compare Images    ${location_img_name_1}[${i}]    ${location_img_name_2}[${i}]   
    \    Click Save Add Object Button  
    
    # 5. Click save and select Rack 01, Cabinet 02, Auxiliary Rack 03 
    # 6. Observe Rack View (Front) on Properties Pane
    :FOR    ${i}    IN RANGE    0    len(${tree_node_contain_object})
    \    Click Tree Node On Site Manager    ${tree_node_contain_object}[${i}]    
    \    Go To Another View On Site Manager    ${RACK_VIEW_FRONT}
    \    Check Image Exist On Rack View    ${splice_enclosure_names}[${i}]    ${splice_enclosure_images_1}[${i}]    

    # 7. Edit Enclosure 01 with Location in Rack: Zero U
    :FOR    ${i}    IN RANGE    0    len(${tree_node_contain_object})
    \    Edit Splice Enclosure    ${tree_node_contain_object}[${i}]/${splice_enclosure_names}[${i}]    locationInRack=Zero U    

    # 8. Observe Rack View (Zero U) on Properties Pane
    :FOR    ${i}    IN RANGE    0    len(${tree_node_contain_object})
    \    Click Tree Node On Site Manager    ${tree_node_contain_object}[${i}]    
    \    Go To Another View On Site Manager    ${RACK_VIEW_ZEROU}
    \    Check Image Exist On Rack View    ${splice_enclosure_names}[${i}]    ${splice_enclosure_images_1}[${i}]    rackViewType=ZeroU  
  
    # 9. Edit Enclosure 01.
    # _Assign it Image 01 
    # _Location in Rack: Front
    # 10. Observe image on Edit Dialog
    
    :FOR    ${i}    IN RANGE    0    len(${tree_node_contain_object})
    \    Edit Splice Enclosure    ${tree_node_contain_object}[${i}]/${splice_enclosure_names}[${i}]    locationInRack=Front    equipmentImageName=${equipment_image_name_2}[${i}]    confirmSave=${False}
    \    Check Equipment Image Exist On Properties Window    ${splice_enclosure_images_2}[${i}]
    \    Click Save Add Object Button

    # 11. Click save and select  Rack 01, Cabinet 02, Auxiliary Rack 03 
    # 12. Observe Rack View (Front)
    :FOR    ${i}    IN RANGE    0    len(${tree_node_contain_object})
    \    Click Tree Node On Site Manager    ${tree_node_contain_object}[${i}]    
    \    Go To Another View On Site Manager    ${RACK_VIEW_FRONT}
    \    Check Image Exist On Rack View    ${splice_enclosure_names}[${i}]    ${splice_enclosure_images_2}[${i}]
    
    # 13. Edit Enclosure 01 and assign it back to default image
    # 14. Observe Image on Edit Dialog

    :FOR    ${i}    IN RANGE    0    len(${tree_node_contain_object})
    \    Edit Splice Enclosure    ${tree_node_contain_object}[${i}]/${splice_enclosure_names}[${i}]    equipmentImageName=${equipment_image_name_3}[${i}]    confirmSave=${False}
    \    Check Equipment Image Exist On Properties Window    ${splice_enclosure_images_1}[${i}]
    \    Click Save Add Object Button

    # 15. Click save and select Rack 01, Cabinet 02, Auxiliary Rack 03 
    # 16. Observe Rack View (Front)
    :FOR    ${i}    IN RANGE    0    len(${tree_node_contain_object})
    \    Click Tree Node On Site Manager    ${tree_node_contain_object}[${i}]    
    \    Go To Another View On Site Manager    ${RACK_VIEW_FRONT}
    \    Check Image Exist On Rack View    ${splice_enclosure_names}[${i}]    ${splice_enclosure_images_1}[${i}]    
    

SM-29729_03 Verify that new image can show correctly after edit Rack Units of Splice Enclosure in Rack/Cabinets/Auxiliary
   
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${BUILDING_NAME_2}/${FLOOR_NAME}/${ROOM_NAME}
    ${ENCLOSURE_1U_RackUnits_FileName}    Set Variable    SpliceEnclosureInRack_2U.png
    
    # 1. Launch and log into SM
    # 2. Add Rack 01, Cabinet 02, Auxiliary Rack 03 to Cable Vault 01, Building 01/Floor 01/Room 01
    # 3. Add Splice Enclosure 01 to Rack 01, Cabinet 02, Auxiliary Rack 03 
    Select Main Menu    ${Site Manager}
    Create Object    ${SITE_NODE}    ${BUILDING_NAME_2}    ${FLOOR_NAME}    ${ROOM_NAME}
    ${tree_node_rack} =     Add Rack    ${tree_node_room}    ${RACK_NAME}    position=1
    ${tree_node_cabinet} =    Add Rack    ${tree_node_room}    ${CABINET_NAME}    rackType=Cabinet (42U)    position=2
    ${tree_node_auxiliary} =    Add Rack    ${tree_node_room}    ${AUXILIARY_NAME}    rackType=Auxiliary Rack    position=3    capacityU=42
    ${tree_node_ndd_rack} =    Add Rack    ${tree_node_room}    ${RACK_NAME_2}    position=4    NDD=${True}
    
    ${tree_node_contain_object}    Create List    ${tree_node_rack}    ${tree_node_cabinet}    ${tree_node_auxiliary}    ${tree_node_ndd_rack}
    ${splice_enclosure_images}    Create List    ${ENCLOSURE_1U_FILENAME}    ${ENCLOSURE_2U_FILENAME}    ${ENCLOSURE_3U_FILENAME}    ${ENCLOSURE_4U_FILENAME}
    ${splice_enclosure_names}    Create List    ${SPLICE_ENCLOSURE_1}    ${SPLICE_ENCLOSURE_2}    ${SPLICE_ENCLOSURE_3}    ${SPLICE_ENCLOSURE_4}
    ${equipment_image_name_1}    Create List    None    ${ENCLOSURE_2U}    ${ENCLOSURE_3U}    ${ENCLOSURE_4U}
    ${racview_image_list}    Create List    ${ENCLOSURE_1U_RackUnits_FILENAME}    ${ENCLOSURE_2U_FILENAME}    ${ENCLOSURE_3U_FILENAME}    ${ENCLOSURE_4U_FILENAME}
    ${rack_units_list}    Create List    2    3    4    5
    
    # 1. Launch and log into SM
    # 2. Add Rack 01, Cabinet 02, Auxiliary Rack 03, NDD Rack 04 to Building 01/Floor 01/Room 01
    # 3. Add Splice Enclosure 01-02-03-04 as below to Rack 01, Cabinet 02, Auxiliary Rack 03, NDD Rack 04
    # _Image : Default (1U) - Image 01 - Image 02 - Image 03 
    # _Rack Units: 2 - 3 - 4 - 5
    :FOR    ${i}    IN RANGE    0    len(${tree_node_contain_object})
    \    Add Splice Enclosure    ${tree_node_contain_object}[${i}]    ${splice_enclosure_names}[${i}]    rackUnits=${rack_units_list}[${i}]    equipmentImageName=${equipment_image_name_1}[${i}]
    
    # 4. Observe Rack View (Front).
    :FOR    ${i}    IN RANGE    0    len(${tree_node_contain_object})
    \    Click Tree Node On Site Manager    ${tree_node_contain_object}[${i}]    
    \    Go To Another View On Site Manager    ${RACK_VIEW_FRONT}
    \    Check Image Exist On Rack View    ${splice_enclosure_names}[${i}]    ${racview_image_list}[${i}]    

SM-29729_04 Verify that new image can show correctly when add Splice Enclosure to Rack/Cabinets/Auxiliary Racks after upgrading SM version
    
    ${room_splice_name}    Set Variable    Room_For_Splice
    ${ENCLOSURE_1U_RackUnits_FileName}    Set Variable    SpliceEnclosureInRack_2U.png
    ${RESTORE_FILE_NAME}    Set Variable    BLE_020_8_1.bak
    
    # 1.Launch and log into SM9.1
    # 2.Add Building 01/Floor 01/Room 01 and Rack 01-Cabinet 02-Auxiliary Rack 03
    # 3.Upgrade to SM9.2
    # 3. Add Image 01,02,03 with image of Splice Enclosure 2U, 3U, 4U in "Equipment Image" of Lists Manger
    Restore Database    ${RESTORE_FILE_NAME}    ${DIR_FILE_BK}
    Login To SM    ${USERNAME}    ${PASSWORD}
    Remove File    ${LOC_RACVIEWIMG_2}
    Remove File    ${LOC_RACVIEWIMG_3}
    Remove File    ${LOC_RACVIEWIMG_4}
    Select Main Menu    ${Administration}    Lists
    Add List On Administration    ${LIST_TYPE}    ${ENCLOSURE_2U}    ${DIR_ENCLOSURE_2U}
    Add List On Administration    ${LIST_TYPE}    ${ENCLOSURE_3U}    ${DIR_ENCLOSURE_3U}
    Add List On Administration    ${LIST_TYPE}    ${ENCLOSURE_4U}    ${DIR_ENCLOSURE_4U}
    
    # 4.Add Enclosure 01 to Rack 01-Cabinet 02-Auxiliary Rack 03
    # 5. Observe Rack view on Add Dialog
    Select Main Menu    ${Site Manager}
    ${tree_node_room} =    Add Room    ${SITE_NODE}/${BUILDING_9.1}/${FLOOR_NAME}    ${room_splice_name}    
    ${tree_node_rack} =     Add Rack    ${tree_node_room}    ${RACK_NAME}    position=1
    ${tree_node_cabinet} =    Add Rack    ${tree_node_room}    ${CABINET_NAME}    rackType=${Cabinet (42U)}    position=2
    ${tree_node_auxiliary} =    Add Rack    ${tree_node_room}    ${AUXILIARY_NAME}    rackType=${Auxiliary Rack}   position=3    capacityU=42
    ${tree_node_ndd_rack} =    Add Rack    ${tree_node_room}    ${RACK_NAME_2}    position=4    NDD=${True}
    
    ${tree_node_contain_object}    Create List    ${tree_node_rack}    ${tree_node_cabinet}    ${tree_node_auxiliary}    ${tree_node_ndd_rack}
    ${splice_enclosure_images_1}    Create List    ${ENCLOSURE_1U_FILENAME}    ${ENCLOSURE_2U_FILENAME}    ${ENCLOSURE_3U_FILENAME}    ${ENCLOSURE_4U_FILENAME}
    ${splice_enclosure_images_2}    Create List    ${ENCLOSURE_2U_FILENAME}    ${ENCLOSURE_3U_FILENAME}    ${ENCLOSURE_4U_FILENAME}    ${ENCLOSURE_1U_FILENAME}
    ${splice_enclosure_names}    Create List    ${SPLICE_ENCLOSURE_1}    ${SPLICE_ENCLOSURE_2}    ${SPLICE_ENCLOSURE_3}    ${SPLICE_ENCLOSURE_4}
    ${equipment_image_name_1}    Create List    None    ${ENCLOSURE_2U}    ${ENCLOSURE_3U}    ${ENCLOSURE_4U}
    ${equipment_image_name_2}    Create List    ${ENCLOSURE_2U}    ${ENCLOSURE_3U}    ${ENCLOSURE_4U}    ${ENCLOSURE_1U}
    ${location_img_name_1}    Create List    ${LOC_RACVIEWIMG_1}    ${LOC_RACVIEWIMG_2}    ${LOC_RACVIEWIMG_3}    ${LOC_RACVIEWIMG_4}
    ${location_img_name_2}    Create List    ${DIR_ENCLOSURE_1U}    ${DIR_ENCLOSURE_2U}    ${DIR_ENCLOSURE_3U}    ${DIR_ENCLOSURE_4U}
    
    # 4. Observe Rack view on Add Dialog
    :FOR    ${i}    IN RANGE    0    len(${tree_node_contain_object})
    \    Add Splice Enclosure    ${tree_node_contain_object}[${i}]    ${splice_enclosure_names}[${i}]    equipmentImageName=${equipment_image_name_1}[${i}]    confirmSave=${False}    waitForExist=${False}
    \    Check Equipment Image Exist On Properties Window    ${splice_enclosure_images_1}[${i}]
    \    Compare Images    ${location_img_name_1}[${i}]    ${location_img_name_2}[${i}]   
    \    Click Save Add Object Button  
    
    # 6. Click save and select Splice Enclosure 01 in  Rack 01, Cabinet 02, Auxiliary Rack 03 
    # 7. Observe Rack View on Properties Pane
    :FOR    ${i}    IN RANGE    0    len(${tree_node_contain_object})
    \    Click Tree Node On Site Manager    ${tree_node_contain_object}[${i}]    
    \    Go To Another View On Site Manager    ${RACK_VIEW_FRONT}
    \    Check Image Exist On Rack View    ${splice_enclosure_names}[${i}]    ${splice_enclosure_images_1}[${i}]    

    # 8. Edit Enclosure 01 and Assign it Image 01 
    # 9. Observe Rack view on Edit Dialog
    
    :FOR    ${i}    IN RANGE    0    len(${tree_node_contain_object})
    \    Edit Splice Enclosure    ${tree_node_contain_object}[${i}]/${splice_enclosure_names}[${i}]    equipmentImageName=${equipment_image_name_2}[${i}]    confirmSave=${False}
    \    Check Equipment Image Exist On Properties Window    ${splice_enclosure_images_2}[${i}]
    \    Click Save Add Object Button

    # 10. Click save and select Splice Enclosure 01 in  Rack 01, Cabinet 02, Auxiliary Rack 03 
    # 11. Observe Rack View
    :FOR    ${i}    IN RANGE    0    len(${tree_node_contain_object})
    \    Click Tree Node On Site Manager    ${tree_node_contain_object}[${i}]    
    \    Go To Another View On Site Manager    ${RACK_VIEW_FRONT}
    \    Check Image Exist On Rack View    ${splice_enclosure_names}[${i}]    ${splice_enclosure_images_2}[${i}]

    