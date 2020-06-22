*** Settings ***
Resource    ../../../../../resources/constants.robot
Resource    ../../../../../resources/icons_constants.robot

Library    ../../../../../py_sources/logigear/setup.py
Library    ../../../../../py_sources/logigear/api/CampusApi.py   ${USERNAME}    ${PASSWORD} 
Library    ../../../../../py_sources/logigear/api/BuildingApi.py  
Library    ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py    
Library    ../../../../../py_sources/logigear/page_objects/system_manager/tools/database_tools/RestoreDatabasePage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/administration/spaces/AdmLayerImageFilesPage${PLATFORM}.py        
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py                   

Default Tags    Cable Vaults Filter
Force Tags    SM-29255
    
*** Test Cases ***
Bulk_SM-29255-01_02_06_Verify That New Object Type Filter To Show Hide Cable Vaults Is Added Into Site Tree
    [Setup]    Run Keywords    Set Test Variable    ${city_name}    City_SM29255_01    
    ...    AND    Set Test Variable    ${campus_name}    Campus_SM29255_01    
    ...    AND    Set Test Variable    ${cablevault_name_1}    CV_SM29255_01
    ...    AND    Set Test Variable    ${cablevault_name_2}    CV_SM29255_02
    ...    AND    Set Test Variable    ${cablevault_name_3}    CV_SM29255_03
    ...    AND    Set Test Variable    ${cablevault_name_4}    CV_SM29255_04
    ...    AND    Set Test Variable    ${cablevault_name_5}    CV_SM29255_05
    ...    AND    Set Test Variable    ${cablevault_name_6}    CV_SM29255_06
    ...    AND    Set Test Variable    ${cablevault_name_7}    CV_SM29255_07
    ...    AND    Set Test Variable    ${cablevault_name_8}    CV_SM29255_08
    ...    AND    Set Test Variable    ${cablevault_name_9}    CV_SM29255_09
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Delete Tree Node If Exist On Site Manager     ${SITE_NODE}/${city_name}
    ...    AND    Delete Campus     name=${campus_name}
    ...    AND    Delete Tree Node If Exist On Site Manager     ${SITE_NODE}/${cablevault_name_7}
    ...    AND    Delete Tree Node If Exist On Site Manager     ${SITE_NODE}/${cablevault_name_8}
    ...    AND    Delete Tree Node If Exist On Site Manager     ${SITE_NODE}/${cablevault_name_9}
    ...    AND    Add New Campus    ${campus_name}    
      
    [Teardown]    Run Keywords    Click Filter Button On Left Tree Site Manager    ${FILTER_CABLEVAULT_BUTTON}    
    ...    AND    Delete Tree Node On Site Manager     ${SITE_NODE}/${city_name}
    ...    AND    Delete Campus     name=${campus_name}
    ...    AND    Delete Tree Node On Site Manager     ${SITE_NODE}/${cablevault_name_7}
    ...    AND    Delete Tree Node On Site Manager     ${SITE_NODE}/${cablevault_name_8}
    ...    AND    Delete Tree Node On Site Manager     ${SITE_NODE}/${cablevault_name_9}
    ...    AND    Close Browser

    [Tags]    Sanity    
    
    ${expected_site_tree_nodes}=    Create List    
    ...    ${SITE_NODE}/${city_name}/${cablevault_name_1}
    ...    ${SITE_NODE}/${city_name}/${cablevault_name_2}
    ...    ${SITE_NODE}/${city_name}/${cablevault_name_3}
    ...    ${SITE_NODE}/${campus_name}/${cablevault_name_4}
    ...    ${SITE_NODE}/${campus_name}/${cablevault_name_5}
    ...    ${SITE_NODE}/${campus_name}/${cablevault_name_6}
    ...    ${SITE_NODE}/${cablevault_name_7}
    ...    ${SITE_NODE}/${cablevault_name_8}
    ...    ${SITE_NODE}/${cablevault_name_9}    
    ${expected_object_name_1}=    Create List    ${cablevault_name_1}    ${cablevault_name_2}    ${cablevault_name_3}
    ${expected_object_name_2}=    Create List    ${cablevault_name_4}    ${cablevault_name_5}    ${cablevault_name_6}
    ${expected_object_name_3}=    Create List    ${cablevault_name_7}    ${cablevault_name_8}    ${cablevault_name_9}
    
    ## TC: SM-29255-02: Verify that  Cable Vault filter icon always show all by default after user closes the session (log out/ close browser)
    # 1. Launch and log into SM
    # 2. Click to change Cable Vault filter icon to Hide icon (with cross-over)
    Click Filter Button On Left Tree Site Manager    ${FILTER_CABLEVAULT_BUTTON} 
    
    # 3. Log out, then log in again to SM
    Logout SM
    Login To SM    ${USERNAME}    ${PASSWORD}
    
    # 4. Observe the Cable Vault filter icon
    # VP: Cable Vault filter icon goes back to default when the user closes the session (log out). Default is All shown
    Check Cable Vaults Filter Icon    ${CABLE_VAULT_WITHOUT_CROSS_ICON}    

    # 5. Click to change Cable Vault filter icon to Hide icon (with cross-over)
    Click Filter Button On Left Tree Site Manager    ${FILTER_CABLEVAULT_BUTTON}

    # 6. Close the browser
    # 7. Re-open browser then launch and log into SM again
    Close Browser
    Open SM Login Page
    Login To SM    ${USERNAME}    ${PASSWORD}
    
    # 8. Observe the Cable Vault filter icon
    # VP: Cable Vault filter icon goes back to default when the user closes the session (log out). Default is All shown
    Check Cable Vaults Filter Icon    ${CABLE_VAULT_WITHOUT_CROSS_ICON}

    ### TC: SM-29255-01: Verify that new object Type filter to show/hide Cable Vaults is added into Site tree
    # 1. There are some objects are added into Site tree as below:
    # _ City 01/ Cable Vault 01, 02, 03
    # _ Campus 01/ Cable Vault 04, 05, 06
    # _ Site/Cable Vault 07, 08, 09
    Add City    ${SITE_NODE}    ${city_name}
    Add Cable Vault    ${SITE_NODE}/${city_name}    ${cablevault_name_1}
    Add Cable Vault    ${SITE_NODE}/${city_name}    ${cablevault_name_2}
    Add Cable Vault    ${SITE_NODE}/${city_name}    ${cablevault_name_3}
    Add Cable Vault    ${SITE_NODE}/${campus_name}    ${cablevault_name_4}
    Add Cable Vault    ${SITE_NODE}/${campus_name}    ${cablevault_name_5}
    Add Cable Vault    ${SITE_NODE}/${campus_name}    ${cablevault_name_6}
    Add Cable Vault    ${SITE_NODE}    ${cablevault_name_7}
    Add Cable Vault    ${SITE_NODE}    ${cablevault_name_8}
    Add Cable Vault    ${SITE_NODE}    ${cablevault_name_9}
    Wait For Object Exist On Content Table    ${cablevault_name_9}
    Close Browser
    
    # # 2. Launch and log into SM
    Open SM Login Page
    Login To SM    ${USERNAME}    ${PASSWORD}

    # 3. Observe the object type filter icons on Site tree
    # VP: _ There is a Cable Vault filter icon displays under Site tree
    # VP: _ This icon is Show All ( without cross-over) as default
    Check Cable Vaults Filter Icon    ${CABLE_VAULT_WITHOUT_CROSS_ICON} 

    # 4. Notice the Cable Vault filter icon is normal (all show)
    # 5. Mouse-over the icon and observe the tooltip
    # VP: Tooltip: "Click to hide Cable Vaults" displays
    
    Check Cable Vaults Filter Icon Tooltip    ${CABLE_VAULT_WITHOUT_CROSS_ICON_TOOLTIP}
    
    # 6. Click on this icon and observe the icon is changed
    Click Filter Button On Left Tree Site Manager    ${FILTER_CABLEVAULT_BUTTON}
    Check Cable Vaults Filter Icon    ${CABLE_VAULT_WITH_CROSS_ICON}    

    # 7. Observe the Cable Vault objects on Site tree
    # VP: All Cable Vaults object on Site tree are hided    
    Check Multi Tree Nodes Not Exist On Site Manager    ${expected_site_tree_nodes}   
        
    # 8. Select Site, City 01, Campus 01 and observe the objects in Contents View
    # VP: All Cable Vaults in Contents view still show    
    Check Multi Objects Exist On Content Table    ${SITE_NODE}    ${expected_object_name_3}
    Check Multi Objects Exist On Content Table    ${SITE_NODE}/${city_name}    ${expected_object_name_1}
    Check Multi Objects Exist On Content Table    ${SITE_NODE}/${campus_name}    ${expected_object_name_2}
   
    # 9. Mouse over the Cable Vault filter icon (icon with cross-over) and observe the tooltip displays
    # VP: Tooltip: "Click to show Cable Vaults" displays
    Check Cable Vaults Filter Icon Tooltip    ${CABLE_VAULT_WITH_CROSS_ICON_TOOLTIP}

    # 10. Click on this icon again and observe the icon is changed
    # VP: The icon is changed back to Show All icon ( without cross-over)
    Click Filter Button On Left Tree Site Manager    ${FILTER_CABLEVAULT_BUTTON}
    Check Cable Vaults Filter Icon    ${CABLE_VAULT_WITHOUT_CROSS_ICON} 
    
    # 11. Observe the objects in Site tree
    # VP: All Cable Vaults object on Site tree are shown again
    Check Multi Tree Nodes Exist On Site Manager    ${expected_site_tree_nodes}
    
    ### SM-29255-06: Verify that Cable Vault filter icon does not change to default if user go to another tab then go back to Site
    # 1. There are some objects are added into Site tree as below:
    # _ City 01/ Cable Vault 01, 02, 03
    # _ Campus 01/ Cable Vault 04, 05, 06
    # _ Site/Cable Vault 07, 08, 09
    # 2. Click to change Cable Vault filter icon to Hide icon (with cross-over)
    Click Filter Button On Left Tree Site Manager    ${FILTER_CABLEVAULT_BUTTON}
    
    # 3. Notice that All Cable Vaults are hided
    # 4. Click on each tab (Administration, Tools, Reports) then click on Site Manager tab to go back to Site
    # 5. Observe the Site tree, Contents view.
    # VP: _ Cable Vault filter still keep as Hide icon (cross-over)
    # VP: _ All Cable Vaults are still hided
    Select Main Menu    ${Administration}
    Select Main Menu    ${Site Manager}
    Check Cable Vaults Filter Icon    ${CABLE_VAULT_WITH_CROSS_ICON}
    Check Multi Tree Nodes Not Exist On Site Manager    ${expected_site_tree_nodes}
    
    Select Main Menu    ${Tools}
    Select Main Menu    ${Site Manager}
    Check Cable Vaults Filter Icon    ${CABLE_VAULT_WITH_CROSS_ICON}
    Check Multi Tree Nodes Not Exist On Site Manager    ${expected_site_tree_nodes}    
   
    Select Main Menu    ${Reports}
    Select Main Menu    ${Site Manager}
    Check Cable Vaults Filter Icon    ${CABLE_VAULT_WITH_CROSS_ICON}
    Check Multi Tree Nodes Not Exist On Site Manager    ${expected_site_tree_nodes}
    
Bulk_SM-29255-04_05_Verify That Cable Vault Filter Function Does Not Affect Patching Cabling Window, Spaces View
  [Setup]    Run Keywords    Set Test Variable    ${sm_29255_04_city_name}    City_SM29255_04    
    ...    AND    Set Test Variable    ${sm_29255_04_campus_name}    Campus_SM29255_04    
    ...    AND    Set Test Variable    ${sm_29255_04_cablevault_name_1}    CV_SM29255_04_01
    ...    AND    Set Test Variable    ${sm_29255_04_cablevault_name_2}    CV_SM29255_04_02
    ...    AND    Set Test Variable    ${sm_29255_04_cablevault_name_3}    CV_SM29255_04_03
    ...    AND    Set Test Variable    ${sm_29255_04_cablevault_name_4}    CV_SM29255_04_04
    ...    AND    Set Test Variable    ${sm_29255_04_cablevault_name_5}    CV_SM29255_04_05
    ...    AND    Set Test Variable    ${sm_29255_04_cablevault_name_6}    CV_SM29255_04_06
    ...    AND    Set Test Variable    ${sm_29255_04_cablevault_name_7}    CV_SM29255_04_07
    ...    AND    Set Test Variable    ${sm_29255_04_cablevault_name_8}    CV_SM29255_04_08
    ...    AND    Set Test Variable    ${sm_29255_04_cablevault_name_9}    CV_SM29255_04_09
    ...    AND    Set Test Variable    ${sm_29255_04_building_name}    Building_SM29255_04
    ...    AND    Set Test Variable    ${sm_29255_04_floor_name}    Floor 01
    ...    AND    Set Test Variable    ${sm_29255_04_room_name}    Room 01
    ...    AND    Set Test Variable    ${sm_29255_04_rack_name}    Rack 001
    ...    AND    Set Test Variable    ${sm_29255_04_panel_name_1}    Panel 01
    ...    AND    Set Test Variable    ${sm_29255_04_panel_name_2}    Panel 02
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
    ...    AND    Delete Tree Node If Exist On Site Manager     ${SITE_NODE}/${sm_29255_04_city_name}
    ...    AND    Delete Campus    name=${sm_29255_04_campus_name}
    ...    AND    Delete Tree Node If Exist On Site Manager     ${SITE_NODE}/${sm_29255_04_cablevault_name_7}
    ...    AND    Delete Tree Node If Exist On Site Manager     ${SITE_NODE}/${sm_29255_04_cablevault_name_8}
    ...    AND    Delete Tree Node If Exist On Site Manager     ${SITE_NODE}/${sm_29255_04_cablevault_name_9}
    ...    AND    Delete Building     name=${sm_29255_04_building_name}
    ...    AND    Add New Campus    ${sm_29255_04_campus_name}    
    ...    AND    Add New Building    ${sm_29255_04_building_name}    
                  
    [Teardown]    Run Keywords    Delete Tree Node On Site Manager     ${SITE_NODE}/${sm_29255_04_city_name}
    ...    AND    Delete Campus     name=${sm_29255_04_campus_name}
    ...    AND    Delete Tree Node On Site Manager     ${SITE_NODE}/${sm_29255_04_cablevault_name_7}
    ...    AND    Delete Tree Node On Site Manager     ${SITE_NODE}/${sm_29255_04_cablevault_name_8}
    ...    AND    Delete Tree Node On Site Manager     ${SITE_NODE}/${sm_29255_04_cablevault_name_9}
    ...    AND    Delete Building    name=${sm_29255_04_building_name}    
    ...    AND    Close Browser
       
    ${expected_tree_nodes}=    Create List
    ...    ${SITE_NODE}/${sm_29255_04_city_name}/${sm_29255_04_cablevault_name_1}      
	...    ${SITE_NODE}/${sm_29255_04_city_name}/${sm_29255_04_cablevault_name_2}
	...    ${SITE_NODE}/${sm_29255_04_city_name}/${sm_29255_04_cablevault_name_3}
	...    ${SITE_NODE}/${sm_29255_04_campus_name}/${sm_29255_04_cablevault_name_4}        
	...    ${SITE_NODE}/${sm_29255_04_campus_name}/${sm_29255_04_cablevault_name_5}
	...    ${SITE_NODE}/${sm_29255_04_campus_name}/${sm_29255_04_cablevault_name_6}	
	...    ${SITE_NODE}/${sm_29255_04_cablevault_name_7}       
	...    ${SITE_NODE}/${sm_29255_04_cablevault_name_8}
	...    ${SITE_NODE}/${sm_29255_04_cablevault_name_9}
	${expected_object_name_1}=    Create List    ${sm_29255_04_cablevault_name_1}    ${sm_29255_04_cablevault_name_2}    ${sm_29255_04_cablevault_name_3}
    ${expected_object_name_2}=    Create List    ${sm_29255_04_cablevault_name_4}    ${sm_29255_04_cablevault_name_5}    ${sm_29255_04_cablevault_name_6}
    ${expected_object_name_3}=    Create List    ${sm_29255_04_cablevault_name_7}    ${sm_29255_04_cablevault_name_8}    ${sm_29255_04_cablevault_name_9}
   
     ### SM-29255-05: Verify that Cable Vault filter function does not affect Spaces view
    # 1. There are some objects are added into Site tree as below:
	# _ City 01/ Cable Vault 01, 02, 03
	# _ Campus 01/ Cable Vault 04, 05, 06
	# _ Site/Cable Vault 07, 08, 09
	# _ Site/ Building 01/ Floor 01/ Room 01
	# 2. Add Rack 001/ RJ-45 Panel 01,02 to each Cable Vault and Room 01
	# 3. Add some Layers into Administration > Layer Image Files
    ${sm_29255_image_name} =    Set Variable    Layer_SM_29255_05    
    ${sm_29255_image_location} =    Set Variable    C:\\Pre Condition\\Layers\\logigear_building.jpg
       

    Select Main Menu    ${Administration}/${Spaces}    ${Layer Image Files} 
    Delete Layer Image Files    ${sm_29255_image_name}    
    Add Layer Image Files    ${sm_29255_image_name}    ${sm_29255_image_location}
    Select Main Menu    ${Site Manager}	

    # ## SM-29255-04: Verify that Cable Vault filter function does not affect Patching/ Cabling window
	# 1. There are some objects are added into Site tree as below:
	# _ City 01/ Cable Vault 01, 02, 03
	# _ Campus 01/ Cable Vault 04, 05, 06
	# _ Site/Cable Vault 07, 08, 09
	# 2. Add Rack 001/ RJ-45 Panel 01,02 to each Cable Vault
	Add City    ${SITE_NODE}    ${sm_29255_04_city_name}
    Add Cable Vault    ${SITE_NODE}/${sm_29255_04_city_name}    ${sm_29255_04_cablevault_name_1}
    Add Cable Vault    ${SITE_NODE}/${sm_29255_04_city_name}    ${sm_29255_04_cablevault_name_2}
    Add Cable Vault    ${SITE_NODE}/${sm_29255_04_city_name}    ${sm_29255_04_cablevault_name_3}
    Add Cable Vault    ${SITE_NODE}/${sm_29255_04_campus_name}    ${sm_29255_04_cablevault_name_4}
    Add Cable Vault    ${SITE_NODE}/${sm_29255_04_campus_name}    ${sm_29255_04_cablevault_name_5}
    Add Cable Vault    ${SITE_NODE}/${sm_29255_04_campus_name}    ${sm_29255_04_cablevault_name_6}
    Add Cable Vault    ${SITE_NODE}    ${sm_29255_04_cablevault_name_7}
    Add Cable Vault    ${SITE_NODE}    ${sm_29255_04_cablevault_name_8}
    Add Cable Vault    ${SITE_NODE}    ${sm_29255_04_cablevault_name_9}
    Add Floor    ${SITE_NODE}/${sm_29255_04_building_name}    ${sm_29255_04_floor_name}
    Add Room    ${SITE_NODE}/${sm_29255_04_building_name}/${sm_29255_04_floor_name}    ${sm_29255_04_room_name}
    
    Add Rack    ${SITE_NODE}/${sm_29255_04_city_name}/${sm_29255_04_cablevault_name_1}    ${sm_29255_04_rack_name}
    Add Generic Panel    ${SITE_NODE}/${sm_29255_04_city_name}/${sm_29255_04_cablevault_name_1}/1:1 ${sm_29255_04_rack_name}    ${sm_29255_04_panel_name_1}   
    Add Rack    ${SITE_NODE}/${sm_29255_04_campus_name}/${sm_29255_04_cablevault_name_4}    ${sm_29255_04_rack_name}
    Add Generic Panel    ${SITE_NODE}/${sm_29255_04_campus_name}/${sm_29255_04_cablevault_name_4}/1:1 ${sm_29255_04_rack_name}    ${sm_29255_04_panel_name_1}
    Add Rack    ${SITE_NODE}/${sm_29255_04_cablevault_name_7}    ${sm_29255_04_rack_name}
    Add Generic Panel    ${SITE_NODE}/${sm_29255_04_cablevault_name_7}/1:1 ${sm_29255_04_rack_name}    ${sm_29255_04_panel_name_1}     
    Add Rack    ${SITE_NODE}/${sm_29255_04_building_name}/${sm_29255_04_floor_name}/${sm_29255_04_room_name}    ${sm_29255_04_rack_name}
    Add Generic Panel    ${SITE_NODE}/${sm_29255_04_building_name}/${sm_29255_04_floor_name}/${sm_29255_04_room_name}/1:1 ${sm_29255_04_rack_name}    ${sm_29255_04_panel_name_2}

	# 3. Click to hide all Cable Vaults
	Click Filter Button On Left Tree Site Manager    ${FILTER_CABLEVAULT_BUTTON}
	
	# 4. Select Building 01
	# 5. Go to Patching windows
	Open Patching Window    ${SITE_NODE}/${sm_29255_04_building_name}	

	# # 6. Observe the result
	# # VP: Cable Vaults are shown in From and To pane of Patching window
	Check Multi Tree Nodes Exist On Patching    From    ${expected_tree_nodes}  	
    Check Multi Tree Nodes Exist On Patching    To    ${expected_tree_nodes}    

	# 7. Create patching from CV 01/ Rack 001/ Panel 01/ 01 to CV 0/ Rack 001/ Panel 01/ 02
	Create Patching    patchFrom=${SITE_NODE}/${sm_29255_04_campus_name}/${sm_29255_04_cablevault_name_4}/1:1 ${sm_29255_04_rack_name}/${sm_29255_04_panel_name_1}
	...    patchTo=${SITE_NODE}/${sm_29255_04_campus_name}/${sm_29255_04_cablevault_name_4}/1:1 ${sm_29255_04_rack_name}/${sm_29255_04_panel_name_1}
    ...    portsFrom=01    portsTo=02    clickNext=${FALSE}
    
	# # 8. Observe the result
	# # VP: User is able to create patching connection successfully
	Check Icon Object On Patching Tree    From    ${SITE_NODE}/${sm_29255_04_campus_name}/${sm_29255_04_cablevault_name_4}/1:1 ${sm_29255_04_rack_name}/${sm_29255_04_panel_name_1}/01    ${PORT_C_UNCABLED_IN_USE_SCHEDULED_ICON}    	
    Check Icon Object On Patching Tree    From    ${SITE_NODE}/${sm_29255_04_campus_name}/${sm_29255_04_cablevault_name_4}/1:1 ${sm_29255_04_rack_name}/${sm_29255_04_panel_name_1}/02    ${PORT_C_UNCABLED_IN_USE_SCHEDULED_ICON}
    Check Icon Object On Patching Tree    To    ${SITE_NODE}/${sm_29255_04_campus_name}/${sm_29255_04_cablevault_name_4}/1:1 ${sm_29255_04_rack_name}/${sm_29255_04_panel_name_1}/01    ${PORT_C_UNCABLED_IN_USE_SCHEDULED_ICON}    	
    Check Icon Object On Patching Tree    To    ${SITE_NODE}/${sm_29255_04_campus_name}/${sm_29255_04_cablevault_name_4}/1:1 ${sm_29255_04_rack_name}/${sm_29255_04_panel_name_1}/02    ${PORT_C_UNCABLED_IN_USE_SCHEDULED_ICON}
	
    # # 9. Close Patching window
    Close Patching Window
    	
	# 10. Select Building 01 Open Cabling window and observe the result
	Open Cabling Window    ${SITE_NODE}/${sm_29255_04_building_name}
	 
	# VP: Cable Vaults are shown in From and To pane of Cabling window
	Check Multi Tree Nodes Exist On Cabling    From    ${expected_tree_nodes}  	
    Check Multi Tree Nodes Exist On Cabling    To    ${expected_tree_nodes}
        
	# # 11. Create cabling from CV 01/ Rack 001/ Panel 01/ 03 to CV 0/ Rack 001/ Panel 01/ 03
    Create Cabling    cableFrom=${SITE_NODE}/${sm_29255_04_city_name}/${sm_29255_04_cablevault_name_1}/1:1 ${sm_29255_04_rack_name}/${sm_29255_04_panel_name_1}/01
    ...    cableTo=${SITE_NODE}/${sm_29255_04_city_name}/${sm_29255_04_cablevault_name_1}/1:1 ${sm_29255_04_rack_name}/${sm_29255_04_panel_name_1}
    ...    portsTo=02    	
    
    # 12. Observe the result.
	# VP: User is able to create cabling connection successfully
    Check Icon Object On Cabling Tree    From    ${SITE_NODE}/${sm_29255_04_city_name}/${sm_29255_04_cablevault_name_1}/1:1 ${sm_29255_04_rack_name}/${sm_29255_04_panel_name_1}/01    ${PORT_C_PANEL_CABLED_AVAILABLE_ICON}    	
    Check Icon Object On Cabling Tree    From    ${SITE_NODE}/${sm_29255_04_city_name}/${sm_29255_04_cablevault_name_1}/1:1 ${sm_29255_04_rack_name}/${sm_29255_04_panel_name_1}/02    ${PORT_C_PANEL_CABLED_AVAILABLE_ICON}
    Check Icon Object On Cabling Tree    To    ${SITE_NODE}/${sm_29255_04_city_name}/${sm_29255_04_cablevault_name_1}/1:1 ${sm_29255_04_rack_name}/${sm_29255_04_panel_name_1}/01    ${PORT_C_PANEL_CABLED_AVAILABLE_ICON}    	
    Check Icon Object On Cabling Tree    To    ${SITE_NODE}/${sm_29255_04_city_name}/${sm_29255_04_cablevault_name_1}/1:1 ${sm_29255_04_rack_name}/${sm_29255_04_panel_name_1}/02    ${PORT_C_PANEL_CABLED_AVAILABLE_ICON}
    Close Cabling Window

    # ### SM-29255-05: Verify that Cable Vault filter function does not affect Spaces view
    # # 1. There are some objects are added into Site tree as below:
	# # _ City 01/ Cable Vault 01, 02, 03
	# # _ Campus 01/ Cable Vault 04, 05, 06
	# # _ Site/Cable Vault 07, 08, 09
	# # _ Site/ Building 01/ Floor 01/ Room 01
	# # 2. Add Rack 001/ RJ-45 Panel 01,02 to each Cable Vault and Room 01
	# # 3. Add some Layers into Administration > Layer Image Files
    # ${sm_29255_image_name} =    Set Variable    Layer_SM_29255_05    
    # ${sm_29255_image_location} =    Set Variable    C:\\Pre Condition\\Layers\\logigear_building.jpg
       

    # Select Main Menu    ${Administration}/${Spaces}    ${Layer Image Files} 
    # Delete Layer Image Files    ${sm_29255_image_name}    
    # Add Layer Image Files    ${sm_29255_image_name}    ${sm_29255_image_location}
    
	# 4. Assign image to City 01, Campus 01
	# 5. Switch to Spaces view
	# 6. Place:
	# _ Cable Vault 01, 02, 03 to City 01
	# _ Cable Vault 04, 05, 06 to Campus 01
	# _ Cable Vault 07, 08, 09 to Geo
	Select Main Menu    ${Site Manager}	
	Click Filter Button On Left Tree Site Manager    ${FILTER_CABLEVAULT_BUTTON}
    Go To Another View On Site Manager    ${Spaces}
    Assign Layer Image To Object    ${SITE_NODE}/${sm_29255_04_city_name}    ${sm_29255_image_name}
            
    Place Object On Space    ${SITE_NODE}/${sm_29255_04_city_name}    ${SITE_NODE}/${sm_29255_04_city_name}/${sm_29255_04_cablevault_name_1}    10,10
    Place Object On Space    objectTreeNode=${SITE_NODE}/${sm_29255_04_city_name}/${sm_29255_04_cablevault_name_2}    position=10,15
    Place Object On Space    objectTreeNode=${SITE_NODE}/${sm_29255_04_city_name}/${sm_29255_04_cablevault_name_3}    position=10,20
    Assign Layer Image To Object    ${SITE_NODE}/${sm_29255_04_campus_name}    ${sm_29255_image_name}
    Place Object On Space    ${SITE_NODE}/${sm_29255_04_campus_name}    ${SITE_NODE}/${sm_29255_04_campus_name}/${sm_29255_04_cablevault_name_4}    15,10
    Place Object On Space    objectTreeNode=${SITE_NODE}/${sm_29255_04_campus_name}/${sm_29255_04_cablevault_name_5}    position=15,15
    Place Object On Space    objectTreeNode=${SITE_NODE}/${sm_29255_04_campus_name}/${sm_29255_04_cablevault_name_6}    position=15,20
    Click Tree Node On Site Manager    ${SITE_NODE}    
    Place Object On Space    ${SITE_NODE}    ${SITE_NODE}/${sm_29255_04_cablevault_name_7}    20,15
    Place Object On Space    objectTreeNode=${SITE_NODE}/${sm_29255_04_cablevault_name_8}    position=20,20
    Place Object On Space    objectTreeNode=${SITE_NODE}/${sm_29255_04_cablevault_name_9}    position=20,25 	

	# 8. On Geo Map, notice there are some placed Cable Vaults
	# 9. Click Cable Vault filter icon to Hide/Show all Cable Vaults
	# 10. Observe Cable Vaults on Site tree and Geo Map
	# _All Cable Vaults on Site tree are hide/show when clicking Cable Vault filter icon to hide/show Cable Vault objects
	# _ All Cable Vault object still placed on Geo even user clicks Cable Vault filter icon to hide/show Cable Vault objects
    Click Tree Node On Site Manager    ${SITE_NODE}/${sm_29255_04_city_name} 
    Click Filter Button On Left Tree Site Manager    ${FILTER_CABLEVAULT_BUTTON}
    Check Multi Tree Nodes Not Exist On Site Manager    ${expected_tree_nodes}    
    Check Tree Node Exist On Site Manager    ${SITE_NODE}/${sm_29255_04_building_name}/${sm_29255_04_floor_name}/${sm_29255_04_room_name}    
    Check Multi Objects Exist On Spaces View    ${SITE_NODE}    ${expected_object_name_3}

    Click Filter Button On Left Tree Site Manager    ${FILTER_CABLEVAULT_BUTTON}   
    Check Multi Tree Nodes Exist On Site Manager    ${expected_tree_nodes}     
    Check Tree Node Exist On Site Manager    ${SITE_NODE}/${sm_29255_04_building_name}/${sm_29255_04_floor_name}/${sm_29255_04_room_name}    
    Check Multi Objects Exist On Spaces View    ${SITE_NODE}    ${expected_object_name_3}    

	# 11. Select City 01, notice there are some placed Cable Vaults
	# 12. Click Cable Vault filter icon to Hide/Show all Cable Vaults
	# 13. Observe Cable Vaults on Site tree and City 01 spaces view
	# _All Cable Vaults on Site tree are hide/show when clicking Cable Vault filter icon to hide/show Cable Vault objects
	# _ All Cable Vault object still placed on City 01 spaces view even user clicks Cable Vault filter icon to hide/show Cable Vault objects
    Click Tree Node On Site Manager    ${SITE_NODE}/${sm_29255_04_city_name}
    Click Filter Button On Left Tree Site Manager    ${FILTER_CABLEVAULT_BUTTON}
    Check Multi Tree Nodes Not Exist On Site Manager    ${expected_tree_nodes}    
    Check Tree Node Exist On Site Manager    ${SITE_NODE}/${sm_29255_04_building_name}/${sm_29255_04_floor_name}/${sm_29255_04_room_name}    
    Check Multi Objects Exist On Spaces View    ${SITE_NODE}/${sm_29255_04_city_name}    ${expected_object_name_1}
     
    Click Filter Button On Left Tree Site Manager    ${FILTER_CABLEVAULT_BUTTON}
    Check Multi Tree Nodes Exist On Site Manager    ${expected_tree_nodes}    
    Check Tree Node Exist On Site Manager    ${SITE_NODE}/${sm_29255_04_building_name}/${sm_29255_04_floor_name}/${sm_29255_04_room_name}    
    Check Multi Objects Exist On Spaces View    ${SITE_NODE}/${sm_29255_04_city_name}    ${expected_object_name_1}    
    
	# 14. Select Campus 01, notice there are some placed Cable Vaults
	# 15. Click Cable Vault filter icon to Hide/Show all Cable Vaults
	# 16. Observe Cable Vaults on Site tree and Campus 01 spaces view
	# _All Cable Vaults on Site tree are hide/show when clicking Cable Vault filter icon to hide/show Cable Vault objects
	# _ All Cable Vault object still placed on Campus 01 spaces view even user clicks Cable Vault filter icon to hide/show Cable Vault objects
    Click Tree Node On Site Manager    ${SITE_NODE}/${sm_29255_04_campus_name}    
    Click Filter Button On Left Tree Site Manager    ${FILTER_CABLEVAULT_BUTTON}
    Check Multi Tree Nodes Not Exist On Site Manager    ${expected_tree_nodes}    
    Check Tree Node Exist On Site Manager    ${SITE_NODE}/${sm_29255_04_building_name}/${sm_29255_04_floor_name}/${sm_29255_04_room_name}
    Check Multi Objects Exist On Spaces View    ${SITE_NODE}/${sm_29255_04_campus_name}    ${expected_object_name_2}

    Click Filter Button On Left Tree Site Manager    ${FILTER_CABLEVAULT_BUTTON}
    Check Multi Tree Nodes Exist On Site Manager    ${expected_tree_nodes} 
    Check Tree Node Exist On Site Manager    ${SITE_NODE}/${sm_29255_04_building_name}/${sm_29255_04_floor_name}/${sm_29255_04_room_name}
    Check Multi Objects Exist On Spaces View    ${SITE_NODE}/${sm_29255_04_campus_name}    ${expected_object_name_2}   
  
SM-29255-07_Verify That Cable Vault Filter Icon Shows And Works On SM After Upgrading From Old SM Version To Latest Version
  [Setup]    Run Keywords    Set Test Variable    ${sm_29255_07_city_name}    City_SM29255_07    
    ...    AND    Set Test Variable    ${sm_29255_07_campus_name}    Campus_SM29255_07    
    ...    AND    Set Test Variable    ${sm_29255_07_cablevault_name_1}    CV_SM29255_07_01
    ...    AND    Set Test Variable    ${sm_29255_07_cablevault_name_2}    CV_SM29255_07_02
    ...    AND    Set Test Variable    ${sm_29255_07_cablevault_name_3}    CV_SM29255_07_03
    ...    AND    Set Test Variable    ${sm_29255_07_cablevault_name_4}    CV_SM29255_07_04
    ...    AND    Set Test Variable    ${sm_29255_07_cablevault_name_5}    CV_SM29255_07_05
    ...    AND    Set Test Variable    ${sm_29255_07_cablevault_name_6}    CV_SM29255_07_06
    ...    AND    Set Test Variable    ${sm_29255_07_cablevault_name_7}    CV_SM29255_07_07
    ...    AND    Set Test Variable    ${sm_29255_07_cablevault_name_8}    CV_SM29255_07_08
    ...    AND    Set Test Variable    ${sm_29255_07_cablevault_name_9}    CV_SM29255_07_09
    ...    AND    Set Test Variable    ${sm_29255_07_building_name}    Building_SM29255_07
    ...    AND    Set Test Variable    ${sm_29255_07_floor_name}    Floor 01
    ...    AND    Set Test Variable    ${sm_29255_07_room_name}    Room 01
    ...    AND    Set Test Variable    ${sm_29255_07_file_bk}    SM9.1_TC_SM_29255_07.bak
              
    [Teardown]    Run Keywords    Delete Tree Node On Site Manager     ${SITE_NODE}/${sm_29255_07_city_name}
    ...    AND    Delete Campus     name=${sm_29255_07_campus_name}
    ...    AND    Delete Tree Node On Site Manager     ${SITE_NODE}/${sm_29255_07_cablevault_name_7}
    ...    AND    Delete Tree Node On Site Manager     ${SITE_NODE}/${sm_29255_07_cablevault_name_8}
    ...    AND    Delete Tree Node On Site Manager     ${SITE_NODE}/${sm_29255_07_cablevault_name_9}
    ...    AND    Delete Building     name=${sm_29255_07_building_name}
    ...    AND    Close Browser
    
    ${expected_tree_nodes}=    Create List
    ...    ${SITE_NODE}/${sm_29255_07_city_name}/${sm_29255_07_cablevault_name_1}      
	...    ${SITE_NODE}/${sm_29255_07_city_name}/${sm_29255_07_cablevault_name_2}
	...    ${SITE_NODE}/${sm_29255_07_city_name}/${sm_29255_07_cablevault_name_3}
	...    ${SITE_NODE}/${sm_29255_07_campus_name}/${sm_29255_07_cablevault_name_4}        
	...    ${SITE_NODE}/${sm_29255_07_campus_name}/${sm_29255_07_cablevault_name_5}
	...    ${SITE_NODE}/${sm_29255_07_campus_name}/${sm_29255_07_cablevault_name_6}	
	...    ${SITE_NODE}/${sm_29255_07_cablevault_name_7}       
	...    ${SITE_NODE}/${sm_29255_07_cablevault_name_8}
	...    ${SITE_NODE}/${sm_29255_07_cablevault_name_9}
	    
    # 1. prepare a machine with previous SM version (e.g 9.0)
    # 2. There are some objects are added into Site tree as below:
    # _ City 01/ Cable Vault 01, 02, 03
    # _ Campus 01/ Cable Vault 04, 05, 06
    # _ Site/Cable Vault 07, 08, 09
    # 3. Launch and log into the latest SM
    # 4. Restore the database
   	Open SM Login Page
	Login To SM    ${USERNAME}    ${PASSWORD}
    Restore Database    ${sm_29255_07_file_bk}    ${DIR_FILE_BK}     
    Login To SM    ${USERNAME}    ${PASSWORD}    
		 	
	# 5. Observe the Site tree
	# VP: _ New Cable Vault filter icon is added at the bottom of Site tree
    # VP: _ Cable Vault filter is Show icon as default
    Check Cable Vaults Filter Icon    ${CABLE_VAULT_WITHOUT_CROSS_ICON}

	# 6. Click to change Cable Vault filter to Hide icon
	# 7. Observe the result
	# VP: _ Cable Vault icon changes to Hide (icon with cross-over)
    # VP: _ All Cable Vaults are hided
    Click Filter Button On Left Tree Site Manager    ${FILTER_CABLEVAULT_BUTTON}
    Check Cable Vaults Filter Icon    ${CABLE_VAULT_WITH_CROSS_ICON}
    Check Multi Tree Nodes Not Exist On Site Manager    ${expected_tree_nodes}
    Check Tree Node Exist On Site Manager    ${SITE_NODE}/${sm_29255_07_building_name}/${sm_29255_07_floor_name}/${sm_29255_07_room_name}
    
	# 8. Click to change Cable Vault filter to Show icon
	# 9. Observe the result
	# VP: _ Cable Vault icon changes to Show
    # VP: _ All Cable Vaults are shown
    Click Filter Button On Left Tree Site Manager    ${FILTER_CABLEVAULT_BUTTON}
    Check Cable Vaults Filter Icon    ${CABLE_VAULT_WITHOUT_CROSS_ICON}
    Check Multi Tree Nodes Exist On Site Manager    ${expected_tree_nodes}
    Check Tree Node Exist On Site Manager    ${SITE_NODE}/${sm_29255_07_building_name}/${sm_29255_07_floor_name}/${sm_29255_07_room_name}    
    