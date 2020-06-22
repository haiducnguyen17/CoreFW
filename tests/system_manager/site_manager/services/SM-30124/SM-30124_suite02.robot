*** Settings ***
Resource    ../../../../../resources/constants.robot       
Resource    ../../../../../resources/icons_constants.robot 

Library    ../../../../../py_sources/logigear/setup.py        
Library    ../../../../../py_sources/logigear/api/BuildingApi.py    ${USERNAME}    ${PASSWORD}
Library    ../../../../../py_sources/logigear/page_objects/system_manager/login/LoginPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/zone_header/ZoneHeaderPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/SiteManagerPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/cabling/CablingPage${PLATFORM}.py       
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/patching/PatchingPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/create_work_order/CreateWorkOrderPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/work_orders/work_order_queue/WorkOrderQueuePage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/connections/front_to_back_cabling/FrontToBackCablingPage${PLATFORM}.py  
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/services/decommission_server/DecommissionServerPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/events/event_log/EventLogPage${PLATFORM}.py
Library    ../../../../../py_sources/logigear/page_objects/system_manager/site_manager/services/move_services/MoveServicesPage${PLATFORM}.py            

Default Tags    Services
Force Tags    SM-30124

*** Variables ***
${FLOOR_NAME}    Floor 01
${ROOM_NAME_1}    Room 01
${ROOM_NAME_2}    Room 02
${RACK_NAME_1}    Rack 001
${RACK_NAME_2}    Rack 002
${SWITCH_NAME}    Switch 01
${SERVER_NAME}    Server 01
${PANEL_NAME_1}    Panel 01
${PANEL_NAME_2}    Panel 02
${FACEPLATE_NAME}    Faceplate 01
${DEVICE_NAME}    Device 01
${ZONE}    1
${POSITION_1}    1
${POSITION_2}    2
${FIRST_NAME}    Tester    
${LAST_NAME}    Logigear

*** Test Cases ***
# Invalid TC due to design changed
# SM-30124-06_Verify that the user can move device for 6xLC EB: MPO24 Switch -> cable 3xMPO -> MPO12 Panel 01 -> patched 6xLC -> LC Panel 02 -> cable -> outlet -> connected -> Device -> assign -> Person
	# [Setup]    Run Keywords    Set Test Variable    ${building_name}    SM-30124-06
    # ...    AND    Set Test Variable    ${work_order}    SM-30124-06   
    # ...    AND    Delete Building     name=${building_name}
    # ...    AND    Add New Building    ${building_name}    
    # ...    AND    Open SM Login Page
    # ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
                
    # [Teardown]    Run Keywords    Delete Building     name=${building_name}
    # ...    AND    Close Browser
    
    # [Tags]    SM-30124
    # ${tree_node_room_1}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME_1}
    # ${tree_node_room_2}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME_2}
    # ${tree_node_rack_1}    Set Variable    ${tree_node_room_1}/${ZONE}:${POSITION_1} ${RACK_NAME_1}
    # ${tree_node_rack_2}    Set Variable    ${tree_node_room_2}/${ZONE}:${POSITION_1} ${RACK_NAME_2}
    # ${tree_node_switch_1}    Set Variable    ${tree_node_rack_1}/${SWITCH_NAME}
    # ${tree_node_switch_2}    Set Variable    ${tree_node_rack_2}/${SWITCH_NAME}
    # ${tree_node_server}    Set Variable    ${tree_node_rack_1}/${SERVER_NAME}    
    # ${tree_node_room_1_panel_1}    Set Variable    ${tree_node_rack_1}/${PANEL_NAME_1}
    # ${tree_node_room_1_panel_2}    Set Variable    ${tree_node_rack_1}/${PANEL_NAME_2}
    # ${tree_node_room_2_panel_1}    Set Variable    ${tree_node_rack_2}/${PANEL_NAME_1}
    # ${tree_node_room_2_panel_2}    Set Variable    ${tree_node_rack_2}/${PANEL_NAME_2}
    # ${tree_node_faceplate_1}    Set Variable    ${tree_node_room_1}/${FACEPLATE_NAME}
    # ${tree_node_faceplate_2}    Set Variable    ${tree_node_room_2}/${FACEPLATE_NAME}   
    # ${device_information_room_1}    Set Variable    ${ROOM_NAME_1}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    # ${device_information_room_2}    Set Variable    ${ROOM_NAME_2}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    # ${device_information_rack_1}    Set Variable    ${ZONE}:${POSITION_1} ${RACK_NAME_1}->${device_information_room_1}
    # ${device_information_rack_2}    Set Variable    ${ZONE}:${POSITION_1} ${RACK_NAME_2}->${device_information_room_2}
    # ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    # ${pair_list}	Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    # ${object_position_list}    Create List    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}
	
	# # 1. Launch and log in SM
	# # 2. Add Building 01/Floor 01/Room 01/Rack 001m Room 02 / Rack 002
	# # 3. Add to Room 01:
	# # _LC Faceplate 01
	# # _Device 01
	# # _Person (assign this person to Device 01)
	# # 4. Add to Room 02:
	# # _LC Faceplate 01
    # # 5. Add to Room 01/Rack 001:
	# # _MPO24 Switch 01 (set Data sevice for port 01)
	# # _MPO12 Generic Panel 01
	# # _LC Generic Panel 02	
	# # 6. Add to Room 02/Rack 001:
	# # _MPO24 Switch 01 (set Data sevice for port 01)
	# # _MPO12 Generic Panel 01
	# # _LC Generic Panel 02
	
    # Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}    
    # Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME_1}
    # Add Rack    ${tree_node_room_1}    ${RACK_NAME_1}   
    # Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME_2} 
    # Add Rack    ${tree_node_room_2}    ${RACK_NAME_2}       
    # Add Faceplate    ${tree_node_room_1}    ${FACEPLATE_NAME}    outletType=${LC}
    # Add Person    ${tree_node_room_1}    ${FIRST_NAME}    ${LAST_NAME}
    # Add Device    ${tree_node_room_1}    ${Computer}    ${DEVICE_NAME}    ${LAST_NAME}, ${FIRST_NAME}    	           
    # Add Faceplate    ${tree_node_room_2}    ${FACEPLATE_NAME}    outletType=${LC}   
    # Add Network Equipment    ${tree_node_rack_1}    ${SWITCH_NAME}
	# Add Network Equipment Port    ${tree_node_switch_1}    name=${01}    portType=${MPO24}    listChannel=${01}    listServiceType=${Data}    quantity=1
	# Add Generic Panel    ${tree_node_rack_1}    ${PANEL_NAME_1}    portType=${MPO}
    # Add Generic Panel    ${tree_node_rack_1}    ${PANEL_NAME_2}    portType=${LC}
	# Add Network Equipment    ${tree_node_rack_2}    ${SWITCH_NAME}
	# Add Network Equipment Port    ${tree_node_switch_2}    name=${01}    portType=${MPO24}    listChannel=${01}    listServiceType=${Data}    quantity=1
	# Add Generic Panel    ${tree_node_rack_2}    ${PANEL_NAME_1}    portType=${MPO}
    # Add Generic Panel    ${tree_node_rack_2}    ${PANEL_NAME_2}    portType=${LC}
	
	# # 7. Create cicuit in Room 01 and Room 02:
	# # _Cable 3xMPO from Switch 01/01 to Panel 01/01-03
	# # _Cable from Panel 02/01-06 to Faceplate 01/01-06 
	
    # Open Cabling Window    ${tree_node_switch_1}    ${01}    
    # Create Cabling    typeConnect=Connect    cableFrom=${tree_node_switch_1}/${01}    cableTo=${tree_node_room_1_panel_1}
    # ...    mpoTab=${MPO24}    mpoType=${Mpo24_3xMpo12}    mpoBranches=${B1},${B2},${B3}
    # ...    portsTo=${01},${02},${03}
    # Close Cabling Window
    # Wait For Port Icon Exist On Content Table    ${01}    ${PortNEMPOServiceCabled}
    
    # Open Cabling Window    ${tree_node_room_1_panel_2}    ${01}
    # :FOR    ${i}    IN RANGE    0    len(${port_list})
    # \    Create Cabling    typeConnect=Connect    cableFrom=${tree_node_room_1_panel_2}/${port_list}[${i}]    cableTo=${tree_node_faceplate_1}    portsTo=${port_list}[${i}]
    # Close Cabling Window 	
    # Wait For Port Icon Exist On Content Table    ${01}    ${PortFDCabledAvailable}    

    # Open Cabling Window    ${tree_node_switch_2}    ${01}
    # Create Cabling    typeConnect=Connect    cableFrom=${tree_node_switch_2}/${01}    cableTo=${tree_node_room_2_panel_1}
    # ...    mpoTab=${MPO24}    mpoType=${Mpo24_3xMpo12}    mpoBranches=${B1},${B2},${B3}
    # ...    portsTo=${01},${02},${03}
    # Close Cabling Window 	
    # Wait For Port Icon Exist On Content Table    ${01}    ${PortNEMPOServiceCabled}
    
    # Open Cabling Window    ${tree_node_room_2_panel_2}    ${01}
    # :FOR    ${i}    IN RANGE    0    len(${port_list})
    # \    Create Cabling    typeConnect=Connect    cableFrom=${tree_node_room_2_panel_2}/${port_list}[${i}]    cableTo=${tree_node_faceplate_2}    portsTo=${port_list}[${i}]           
    # Close Cabling Window 	
    # Wait For Port Icon Exist On Content Table    ${01}    ${PortFDCabledAvailable}    
	
	# # 8. Patch 6xLC EB from Panel 01/01 to Panel 02/01-06 in Room 01 and complete job
    
    # Open Patching Window    ${tree_node_room_1_panel_1}    ${01}
    # Create Patching    patchFrom=${tree_node_room_1_panel_1}    patchTo=${tree_node_room_1_panel_2}
    # ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}
    # ...    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}   createWo=${True}    clickNext=${True}
    # Create Work Order    ${work_order}    	
    # Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOServiceCabledInUseScheduled}    
    # Open Work Order Queue Window
    # Complete Work Order    ${work_order}
    # Close Work Order Queue
    # Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOServiceCabledInUse}

	# # 9. Connect Faceplate 01/01 to Device 01

    # Open Patching Window    ${tree_node_faceplate_1}    ${01}
    # Create Patching    patchFrom=${tree_node_faceplate_1}    patchTo=${tree_node_room_1}
    # ...    portsFrom=${01}    portsTo=${DEVICE_NAME}    createWo=${False}    clickNext=${True}
    # Wait For Port Icon Exist On Content Table    ${01}    ${PortFDCabledInUse}        	

	# # 10. Select Room 01/Device 01 and move service
	# # 11. Select Room 02 in Move To pane and go next screen
	# # 12. In Move Service for Device 01 window, select Faceplate 01/01 in Room 02 and search service
	# # 13. Observe the result
	# # Service Found
	# # 14. Create "Move Service" job
	
	# Open Services Window    serviceType=${Move Services}    treeNode=${tree_node_room_1}/${DEVICE_NAME}
	# Move Services    moveTo=${tree_node_room_2}    moveServiceTo=${tree_node_faceplate_2}/${01}
	# Create Work Order    ${work_order}   	
         	
	# # 15. Select Faceplate 01/01 in Room 01, trace and observe the circuit
	# # _Current View: Data service box -> connected -> Switch 01/24 1 [A1] -> cabled 3xMPO to -> Panel 01/01 -> patched 6xLC EB to -> Panel 02/1 [Pair 1] -> cabled to -> Faceplate 01/01 -> connected to -> Device 1 -> assigned to -> Person
    # # _Schedule View: Faceplate 01/01 -> cabled to -> Panel 01/01
    
    # Click Tree Node On Site Manager    ${tree_node_faceplate_1}    
    # Wait For Port Icon Exist On Content Table    ${01}    ${PortFDCabledAvailableScheduled}
    # Open Trace Window    ${tree_node_faceplate_1}    ${01}    	    
	# Check Total Trace On Site Manager    7    	
	# Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=${Trace Service Object}
	# ...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
	# Check Trace Object On Site Manager    indexObject=2    objectPosition=${1} [${A1}]    objectPath=${tree_node_switch_1}/${01}
	# ...    objectType=${Trace Switch}    mpoType=${24}    portIcon=${PortNEMPOServiceCabled}    connectionType=${TRACE_MPO24_3X_MPO12_FRONT_BACK_CABLING}
	# ...    informationDevice=${01}->${SWITCH_NAME}->${device_information_rack_1}
	# Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [${A1}/${B1}]    objectPath=${tree_node_room_1_panel_1}/${01}    objectType=${Trace Generic MPO Panel}
	# ...    mpoType=${12}    portIcon=${PortMPOServiceCabledAvailableScheduled}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	# ...    informationDevice=${01}->${PANEL_NAME_1}->${device_information_rack_1}
	# Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${Pair 1}]    objectPath=${tree_node_room_1_panel_2}/${01}
	# ...    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    portIcon=${PortFDCabledAvailableScheduled}    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	# ...    connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}
	# Check Trace Object On Site Manager    indexObject=5    objectPosition=${1}    objectPath=${tree_node_faceplate_1}/${01}
	# ...    objectType=${TRACE_LC_FACEPLATE_IMAGE}    portIcon=${PortFDCabledAvailableScheduled}    informationDevice=${01}->${FACEPLATE_NAME}->${device_information_room_1}
	# ...    connectionType=${TRACE_FIBER_PATCHING}    
    # Check Trace Object On Site Manager    indexObject=6    objectPath=${tree_node_room_1}/${DEVICE_NAME}
	# ...    objectType=${TRACE_COMPUTER_IMAGE}    informationDevice=${DEVICE_NAME}->${IP}:->${EMPTY}->${MAC}:
	# ...    connectionType=${TRACE_CONNECT_TYPE}
	# Check Trace Object On Site Manager    indexObject=7    objectPosition=${LAST_NAME}, ${FIRST_NAME}    objectPath=${tree_node_room_1}/${LAST_NAME}, ${FIRST_NAME}
	# ...    objectType=${TRACE_PERSON_IMAGE}    portIcon=${PersonSmall}    informationDevice=${LAST_NAME}, ${FIRST_NAME}->${device_information_room_1}
    
    # Select View Type On Trace    ${Scheduled}
    # Check Total Trace On Site Manager    2    	
	# Check Trace Object On Site Manager    indexObject=1    objectPosition=${1}    objectPath=${tree_node_room_1_panel_2}/${01}
	# ...    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    portIcon=${PortFDCabledAvailableScheduled}    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	# ...    connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}
	# Check Trace Object On Site Manager    indexObject=2    objectPosition=${1}    objectPath=${tree_node_faceplate_1}/${01}
	# ...    objectType=${TRACE_LC_FACEPLATE_IMAGE}    portIcon=${PortFDCabledAvailableScheduled}    informationDevice=${01}->${FACEPLATE_NAME}->${device_information_room_1}
    # Close Trace Window       
 	
	# # 16. Select Faceplate 01/01 in Room 02, trace and observe the circuit
	# # _Current View: Faceplate 01/01 -> cabled to -> Panel 02/01
    # # _Schedule View: 
    # # Data service box -> connected -> Switch 01/24 1 [A1] -> cabled 3xMPO to -> Panel 01/01 -> patched 4xLC to -> Panel 02/1 [Pair 1] -> cabled to -> Faceplate 01/01 -> connected to (Schedule icon) -> Device 1 -> assigned to (Schedule icon) -> Person

	# Open Trace Window    ${tree_node_faceplate_2}    ${01}
	# Check Total Trace On Site Manager    2    	
	# Check Trace Object On Site Manager    indexObject=1    objectPosition=${1}    objectPath=${tree_node_room_2_panel_2}/${01}
	# ...    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    portIcon=${PortFDCabledInUseScheduled}    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_2}
	# ...    connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}
	# Check Trace Object On Site Manager    indexObject=2    objectPosition=${1}    objectPath=${tree_node_faceplate_2}/${01}
	# ...    objectType=${TRACE_LC_FACEPLATE_IMAGE}    portIcon=${PortFDCabledInUseScheduled}    informationDevice=${01}->${FACEPLATE_NAME}->${device_information_room_2}
    
    # Select View Type On Trace    ${Scheduled}    	    
	# Check Total Trace On Site Manager    7    	
	# Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=${Trace Service Object}
	# ...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
	# Check Trace Object On Site Manager    indexObject=2    objectPosition=${1} [${A1}]    objectPath=${tree_node_switch_2}/${01}
	# ...    objectType=${Trace Switch}    mpoType=${24}    portIcon=${PortNEMPOServiceCabled}    connectionType=${TRACE_MPO24_3X_MPO12_FRONT_BACK_CABLING}
	# ...    informationDevice=${01}->${SWITCH_NAME}->${device_information_rack_2}
	# Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [${A1}/${B1}]    objectPath=${tree_node_room_2_panel_1}/${01}    objectType=${Trace Generic MPO Panel}
	# ...    mpoType=${12}    portIcon=${PortMPOServiceCabledInUseScheduled}    connectionType=${TRACE_MPO12_4LC_PATCHING}
	# ...    informationDevice=${01}->${PANEL_NAME_1}->${device_information_rack_2}
	# Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${1-1}]    objectPath=${tree_node_room_2_panel_2}/${01}
	# ...    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    portIcon=${PortFDCabledInUseScheduled}    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_2}
	# ...    connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}
	# Check Trace Object On Site Manager    indexObject=5    objectPosition=${1}    objectPath=${tree_node_faceplate_2}/${01}
	# ...    objectType=${TRACE_LC_FACEPLATE_IMAGE}    portIcon=${PortFDCabledInUseScheduled}    informationDevice=${01}->${FACEPLATE_NAME}->${device_information_room_2}
	# ...    connectionType=${TRACE_FIBER_PATCHING}    
    # Check Trace Object On Site Manager    indexObject=6    objectPath=${tree_node_room_1}/${DEVICE_NAME}
	# ...    objectType=${TRACE_COMPUTER_IMAGE}    informationDevice=${DEVICE_NAME}->${IP}:->${EMPTY}->${MAC}:
	# ...    connectionType=${TRACE_CONNECT_TYPE}
	# Check Trace Object On Site Manager    indexObject=7    objectPosition=${LAST_NAME}, ${FIRST_NAME}    objectPath=${tree_node_room_1}/${LAST_NAME}, ${FIRST_NAME}
	# ...    objectType=${TRACE_PERSON_IMAGE}    portIcon=${PersonSmall}    informationDevice=${LAST_NAME}, ${FIRST_NAME}->${device_information_room_1}
    # Close Trace Window    
    
	# # 17. Clear Person Moved priority event and complete job
	# Open Events Window
	# Clear Event On Event Log    All    
	# Close Event Log
	
    # Open Work Order Queue Window
    # Complete Work Order    ${work_order}
    # Close Work Order Queue	
    # Wait For Port Icon Exist On Content Table    ${01}    ${PortFDCabledInUse}    

	# # 18. Trace Panel 01/01 in Room 01 and observe
	# # _Pair 1: Data service box -> connected -> Switch 01/01 -> cabled 3xMPO -> Panel 01/01 -> patch 6xLC EB
	# # _Pair 2: Data service box -> connected -> Switch 01/01 -> cabled 3xMPO -> Panel 01/01 -> patch 6xLC EB -> Panel 02/2 [Pair 2] -> cable -> Faceplate 01/02
	# # ...
	# # _Pair 4: Data service box -> connected -> Switch 01/01 -> cabled 3xMPO -> Panel 01/01 -> patch 6xLC EB -> Panel 02/4 [Pair 4] -> cable -> Faceplate 01/04
	# # _No Path for pair 5 and 6 for Panel
	
    # Open Trace Window    ${tree_node_room_1_panel_1}    ${01}    
    # Check Total Trace On Site Manager    3    	
	# Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=${Trace Service Object}
	# ...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
	# Check Trace Object On Site Manager    indexObject=2    objectPosition=${1} [${A1}]    objectPath=${tree_node_switch_1}/${01}
	# ...    objectType=${Trace Switch}    mpoType=${24}    portIcon=${PortNEMPOServiceCabled}    connectionType=${TRACE_MPO24_3X_MPO12_FRONT_BACK_CABLING}
	# ...    informationDevice=${01}->${SWITCH_NAME}->${device_information_rack_1}
	# Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [${A1}/${B1}]    objectPath=${tree_node_room_1_panel_1}/${01}    objectType=${Trace Generic MPO Panel}
	# ...    mpoType=${12}    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	# ...    informationDevice=${01}->${PANEL_NAME_1}->${device_information_rack_1}
	
    # :FOR    ${i}    IN RANGE    1    4     
    # \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]
	# \	Check Total Trace On Site Manager    5    	
	# \	Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=${Trace Service Object}
		# ...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
	# \	Check Trace Object On Site Manager    indexObject=2    objectPosition=${1} [${A1}]    objectPath=${tree_node_switch_1}/${01}
		# ...    objectType=${Trace Switch}    mpoType=${24}    portIcon=${PortNEMPOServiceCabled}    connectionType=${TRACE_MPO24_3X_MPO12_FRONT_BACK_CABLING}
		# ...    informationDevice=${01}->${SWITCH_NAME}->${device_information_rack_1}
	# \	Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [${A1}/${B1}]    objectPath=${tree_node_room_1_panel_1}/${01}    objectType=${Trace Generic MPO Panel}
		# ...    mpoType=${12}    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
		# ...    informationDevice=${01}->${PANEL_NAME_1}->${device_information_rack_1}
	# \	Check Trace Object On Site Manager    indexObject=4    objectPosition=${object_position_list}[${i}] [${pair_list}[${i}]]   objectPath=${tree_node_room_1_panel_2}/${port_list}[${i}]
		# ...    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    portIcon=${PortFDCabledInUse}    informationDevice=${port_list}[${i}]->${PANEL_NAME_2}->${device_information_rack_1}
		# ...    connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}
	# \	Check Trace Object On Site Manager    indexObject=5    objectPosition=${object_position_list}[${i}]    objectPath=${tree_node_faceplate_1}/${port_list}[${i}]
		# ...    objectType=${TRACE_LC_FACEPLATE_IMAGE}    portIcon=${PortFDCabledInUse}    informationDevice=${port_list}[${i}]->${FACEPLATE_NAME}->${device_information_room_1}
	
    # :FOR    ${i}    IN RANGE    4    6  
    # \    Select View Trace Tab On Site Manager    ${pair_list}[${i}]   
	# \	Check Total Trace On Site Manager    3   		
	# \	Check Trace Object On Site Manager    indexObject=1    objectPosition=${1} [${A1}]    objectPath=${tree_node_room_1_panel_1}/${01}    objectType=${Trace Generic MPO Panel}
		# ...    mpoType=${12}    portIcon=${Trace No Path}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
		# ...    informationDevice=${No Path}->${PANEL_NAME_1}->${device_information_rack_1}
	# \	Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}] [${pair_list}[${i}]]   objectPath=${tree_node_room_1_panel_2}/${port_list}[${i}]
		# ...    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    portIcon=${PortFDCabledInUse}    informationDevice=${port_list}[${i}]->${PANEL_NAME_2}->${device_information_rack_1}
		# ...    connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}
	# \	Check Trace Object On Site Manager    indexObject=3    objectPosition=${object_position_list}[${i}]    objectPath=${tree_node_faceplate_1}/${port_list}[${i}]
		# ...    objectType=${TRACE_LC_FACEPLATE_IMAGE}    portIcon=${PortFDCabledInUse}    informationDevice=${port_list}[${i}]->${FACEPLATE_NAME}->${device_information_room_1}
    # Close Trace Window

	# # 19. Trace Panel 01/01 in Room 02 and observe
	# # _Tab 1-1: Data service box -> connected -> Switch 01/24 1 [A1] -> cabled 3xMPO to -> Panel 01/01 -> patched 4xLC to -> Panel 02/1 [Pair 1] -> cabled to -> Faceplate 01/01 -> connected to -> Device 1 -> assigned to -> Person
	# Open Trace Window    ${tree_node_room_2_panel_1}    ${01}
	# Check Total Trace On Site Manager    7    	
	# Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}: ${Data}    objectType=${Trace Service Object}
	# ...    connectionType=${Trace Assign}    informationDevice=${Service}:->${Data}->${VLAN}:->${Config}:
	# Check Trace Object On Site Manager    indexObject=2    objectPosition=${1} [${A1}]    objectPath=${tree_node_switch_2}/${01}
	# ...    objectType=${Trace Switch}    mpoType=${24}    portIcon=${PortNEMPOServiceCabled}    connectionType=${TRACE_MPO24_3X_MPO12_FRONT_BACK_CABLING}
	# ...    informationDevice=${01}->${SWITCH_NAME}->${device_information_rack_2}
	# Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [${A1}/${B1}]    objectPath=${tree_node_room_2_panel_1}/${01}    objectType=${Trace Generic MPO Panel}
	# ...    mpoType=${12}    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO12_4LC_PATCHING}
	# ...    informationDevice=${01}->${PANEL_NAME_1}->${device_information_rack_2}
	# Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${1-1}]    objectPath=${tree_node_room_2_panel_2}/${01}
	# ...    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    portIcon=${PortFDCabledInUse}    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_2}
	# ...    connectionType=${TRACE_FIBER_BACK_TO_BACK_CABLING}
	# Check Trace Object On Site Manager    indexObject=5    objectPosition=${1}    objectPath=${tree_node_faceplate_2}/${01}
	# ...    objectType=${TRACE_LC_FACEPLATE_IMAGE}    portIcon=${PortFDCabledInUse}    informationDevice=${01}->${FACEPLATE_NAME}->${device_information_room_2}
	# ...    connectionType=${TRACE_FIBER_PATCHING}    
    # Check Trace Object On Site Manager    indexObject=6    objectPath=${tree_node_room_2}/${DEVICE_NAME}
	# ...    objectType=${TRACE_COMPUTER_IMAGE}    informationDevice=${DEVICE_NAME}->${IP}:->${EMPTY}->${MAC}:
	# ...    connectionType=${TRACE_CONNECT_TYPE}
	# Check Trace Object On Site Manager    indexObject=7    objectPosition=${LAST_NAME}, ${FIRST_NAME}    objectPath=${tree_node_room_1}/${LAST_NAME}, ${FIRST_NAME}
	# ...    objectType=${TRACE_PERSON_IMAGE}    portIcon=${PersonSmall}    informationDevice=${LAST_NAME}, ${FIRST_NAME}->${device_information_room_1}
    # Close Trace Window 

SM-30124-10_Verify that the user can decommission server with 6xLC EB: LC Switch -> patched 4xLC to -> MPO12 Panel -> cabled to -> MPO12 Panel -> patched 6xLC to -> LC Server
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    SM-30124-10
    ...    AND    Set Test Variable    ${work_order}    SM-30124-10
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Add New Building    ${building_name}    
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
                
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
        
    [Tags]    Sanity
    
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME_1}
    ${tree_node_rack_1}    Set Variable    ${tree_node_room}/${ZONE}:${POSITION_1} ${RACK_NAME_1}
    ${tree_node_rack_2}    Set Variable    ${tree_node_room}/${ZONE}:${POSITION_2} ${RACK_NAME_2}
    ${tree_node_switch}    Set Variable    ${tree_node_rack_1}/${SWITCH_NAME}
    ${tree_node_server}    Set Variable    ${tree_node_rack_1}/${SERVER_NAME}    
    ${tree_node_panel_1}    Set Variable    ${tree_node_rack_1}/${PANEL_NAME_1}
    ${tree_node_panel_2}    Set Variable    ${tree_node_rack_1}/${PANEL_NAME_2}
    ${device_information_rack_1}    Set Variable    ${ZONE}:${POSITION_1} ${RACK_NAME_1}->${ROOM_NAME_1}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${pair_list_1}	Create List    ${2-2}    ${3-3}    ${4-4}
    ${pair_list_2}	Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${object_position_list}    Create List    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}
                    
	# 1. Launch and log in SM
	# 2. Add Building 01/Floor 01/Room 01/Rack 001	  
    
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}    
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME_1}
    Add Rack    ${tree_node_room}    ${RACK_NAME_1}        
    
	# 3. Add to Rack 001:
	# _LC Switch 01
	# _MPO Generic Panel 01
	# _MPO Generic Panel 02
	# _LC Server 01
	
    Add Network Equipment    ${tree_node_rack_1}    ${SWITCH_NAME}
	Add Network Equipment Port    ${tree_node_rack_1}/${SWITCH_NAME}    name=${01}    portType=${LC}    quantity=6
	Add Generic Panel    ${tree_node_rack_1}    ${PANEL_NAME_1}    portType=${MPO}
    Add Generic Panel    ${tree_node_rack_1}    ${PANEL_NAME_2}    portType=${MPO}    
    Add Device In Rack    ${tree_node_rack_1}    ${SERVER_NAME}
    Add Device In Rack Port    ${tree_node_server}    ${01}    portType=${LC}    quantity=6	
	
	# 4. Patch 4xLC from Panel 01/01 to Switch 01/01-06
    Open Patching Window    ${tree_node_panel_1}    ${01}
    Create Patching    patchFrom=${tree_node_panel_1}    patchTo=${tree_node_switch}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04}    mpoTab=${MPO12}    mpoType=${Mpo12_4xLC}    mpoBranches=${1-1},${2-2},${3-3},${4-4}   createWo=${False}    clickNext=${True}	
    Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOPanelUncabledInUse}

	# 5. Cable MPO12-MPO12 from Panel 01/01 to Panel 02/01
    Open Cabling Window    ${tree_node_panel_1}    ${01}    
    Create Cabling    typeConnect=Connect    cableFrom=${tree_node_panel_1}/${01}    cableTo=${tree_node_panel_2}
    ...    mpoTab=${MPO12}    mpoType=${Mpo12_Mpo12}    portsTo=${01}
    Close Cabling Window 	
    Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOPanelCabledInUse}

	# 6. Patch 6xLC EB from Panel 02/01 to Server 01/01-06
    Open Patching Window    ${tree_node_panel_2}    ${01}
    Create Patching    patchFrom=${tree_node_panel_2}    patchTo=${tree_node_server}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}   createWo=${False}    clickNext=${True}	
    Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOPanelCabledInUse}
        

	# 7. Select Server 01 and decommission server
	# 8. In Remove Patch Connection window:
	# _Set on option:
	# Select patch connections to retain
	# _Set off option:
	# Delete server from the database after the work order is completed
	# 9. Continue to go next window and un-check connection between:
	# _Switch 01/01 and Panel 01/01
	# _Server 01/01 and Panel 02/01
	# 10. Continue to go to Decommission for Server 01
	# 11. Create Decommission Server job
		
    Open Services Window    ${Decommission Server}    ${tree_node_server}
    Decommission Server    3    ${False}
    Remove Patching On Decommission Server Window    ${01}    1,3        
    Create Work Order    ${work_order}	
    Wait For Object Exist On Content Table    ${SWITCH_NAME}
	
	# 12. Check ports status
	# _Switch 01/01: In Use
	# _Switch 01/02-04: Available - Pending
	# _Panel 01/01: Available - Pending
	# _Panel 02/01: Available - Pending
	# _Server 01/01: In Use
	# _Server 01/02-06: Available - Pending
	
    Click Tree Node On Site Manager    ${tree_node_switch}  
    Wait For Port Icon Exist On Content Table    ${01}    ${PortFDUncabledInUse}      
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}   1
	:FOR    ${i}    IN RANGE    1    4
    \    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available - Pending}   ${i+1}
	
	Click Tree Node On Site Manager    ${tree_node_panel_1}
	Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOPanelCabledAvailableScheduled}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}   1
			
    Click Tree Node On Site Manager    ${tree_node_panel_2}
    Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOPanelCabledAvailableScheduled}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}   1    

    Click Tree Node On Site Manager    ${tree_node_server}
    Wait For Port Icon Exist On Content Table    ${01}    ${PortFDUncabledInUse}    
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}   1
    :FOR    ${i}    IN RANGE    1    6
    \    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available - Pending}   ${i+1}       
	
	# 13. Complete job above and observe port status
	# _Switch 01/01: In Use
	# _Switch 01/02-04: Avaiable
	# _Panel 01/01: In Use - 1/4
	# _Panel 02/01: In Use - 1/6
	# _Server 01/01: In Use
	# _Server 01/02-06: Available
    
    Open Work Order Queue Window    
	Complete Work Order    ${work_order}
	Close Work Order Queue	
        
    Click Tree Node On Site Manager    ${tree_node_switch}    
    Wait For Port Icon Exist On Content Table    ${01}    ${PortFDUncabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use }   1
	:FOR    ${i}    IN RANGE    1    4
    \    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}   ${i+1}
	
	Click Tree Node On Site Manager    ${tree_node_panel_1}
	Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOPanelCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - 1/4}   1
			
    Click Tree Node On Site Manager    ${tree_node_panel_2}
    Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOPanelCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - 1/6}   1    

    Click Tree Node On Site Manager    ${tree_node_server}
    Wait For Port Icon Exist On Content Table    ${01}    ${PortFDUncabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}   1
    :FOR    ${i}    IN RANGE    1    6
    \    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}   ${i+1}  	

	# 14. Trace Panel 01/01 and observe the circuit
	# _Tab 1-1: Service box -> connected to -> Switch 01/1 [1-1] -> patched 4xLC to -> Panel 01/01 -> cabled to -> Panel 02/01 -> patched 6xLC EB to -> Server 01/1 [Pair 1]
	# _Tab 2-2, 3-3, 4-4: patched 4xLC to -> Panel 01/01 -> cabled to -> Panel 02/01 -> patched 6xLC EB to
    
    Open Trace Window    ${tree_node_panel_1}    ${01}    	    
	Check Total Trace On Site Manager    5    	
	Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}:    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${EMPTY}->${VLAN}:->${Config}:
	Check Trace Object On Site Manager    indexObject=2    objectPosition=${1} [${1-1}]    objectPath=${tree_node_switch}/${01}    objectType=${Trace Switch}
	...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_LC_4X_MPO12_PATCHING}    informationDevice=${01}->${SWITCH_NAME}->${device_information_rack_1}
	Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_1}/${01}    objectType=${Trace Generic MPO Panel}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	...    informationDevice=${01}->${PANEL_NAME_1}->${device_information_rack_1}
	Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}
	...    objectType=${Trace Generic MPO Panel}    portIcon=${PortMPOPanelCabledInUse}    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	...    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	Check Trace Object On Site Manager    indexObject=5    objectPosition=${1} [${Pair 1}]    objectPath=${tree_node_server}/${01}
	...    objectType=${Trace Generic MPO Panel}    portIcon=${PortFDUncabledInUse}    informationDevice=${01}->${SERVER_NAME}->${device_information_rack_1}
	    
    :FOR    ${i}    IN RANGE    0    len(${pair_list_1})     
	\    Select View Trace Tab On Site Manager    ${pair_list_1}[${i}]	    
	\    Check Total Trace On Site Manager    2  	
	\    Check Trace Object On Site Manager    indexObject=1    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_1}/${01}    objectType=${Trace Generic MPO Panel}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_LC_4X_MPO12_PATCHING}
	...    informationDevice=${01}->${PANEL_NAME_1}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}
	...    objectType=${Trace Generic MPO Panel}    portIcon=${PortMPOPanelCabledInUse}    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=3    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
    Close Trace Window

	# 15. Trace Panel 02/01 and observe the circuit
	# _Pair 1: Service box -> connected to -> Switch 01/1 [1-1] -> patched 4xLC to -> Panel 01/01 -> cabled to -> Panel 02/01 -> patched 6xLC EB to -> Server 01/1 [Pair 1]
	# _Pair 2-6: patched 4xLC to -> Panel 01/01 -> cabled to -> Panel 02/01 -> patched 6xLC EB to
	
	Open Trace Window    ${tree_node_panel_2}    ${01}    	    
	Check Total Trace On Site Manager    5    	
	Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}:    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${EMPTY}->${VLAN}:->${Config}:
	Check Trace Object On Site Manager    indexObject=2    objectPosition=${1} [${1-1}]    objectPath=${tree_node_switch}/${01}    objectType=${Trace Switch}
	...    portIcon=${PortFDUncabledInUse}    connectionType=${TRACE_LC_4X_MPO12_PATCHING}    informationDevice=${01}->${SWITCH_NAME}->${device_information_rack_1}
	Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_1}/${01}    objectType=${Trace Generic MPO Panel}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	...    informationDevice=${01}->${PANEL_NAME_1}->${device_information_rack_1}
	Check Trace Object On Site Manager    indexObject=4    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}
	...    objectType=${Trace Generic MPO Panel}    portIcon=${PortMPOPanelCabledInUse}    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	...    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	Check Trace Object On Site Manager    indexObject=5    objectPosition=${1} [${Pair 1}]    objectPath=${tree_node_server}/${01}
	...    objectType=${Trace Generic MPO Panel}    portIcon=${PortFDUncabledInUse}    informationDevice=${01}->${SERVER_NAME}->${device_information_rack_1}
	
    Report Bug    SM-30437    
    :FOR    ${i}    IN RANGE    1    4     
	\    Select View Trace Tab On Site Manager    ${pair_list_2}[${i}]	    
	\    Check Total Trace On Site Manager    2   	
	\    Check Trace Object On Site Manager    indexObject=1    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}
	...    objectType=${Trace Generic MPO Panel}    portIcon=${PortMPOPanelCabledInUse}    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
	...    connectionType=${TRACE_LC_6X_MPO12_EB_PATCHING}
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_1}/${01}    objectType=${Trace Generic MPO Panel}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	...    informationDevice=${01}->${PANEL_NAME_1}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=3    connectionType=${TRACE_MPO12_4LC_PATCHING}    
    
    :FOR    ${i}    IN RANGE    4    6     
	\    Select View Trace Tab On Site Manager    ${pair_list_2}[${i}]	    
	\    Check Total Trace On Site Manager    2   	
	\    Check Trace Object On Site Manager    indexObject=1    objectPosition=${1}    objectPath=${tree_node_panel_1}/${01}
	...    objectType=${Trace Generic MPO Panel}    portIcon=${Trace No Path}    informationDevice=${No Path}->${PANEL_NAME_1}->${device_information_rack_1}
	...    connectionType=${TRACE_MPO12_BACK_TO_BACK_CABLING}
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_2}/${01}    objectType=${Trace Generic MPO Panel}
	...    mpoType=${12}    portIcon=${PortMPOPanelCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_EB_PATCHING}
	...    informationDevice=${01}->${PANEL_NAME_2}->${device_information_rack_1}
    Close Trace Window    

SM-30124-11_Verify that the user can decommission server with 6xLC EB: LC Switch -> cabled 6xLC to -> MPO12 Panel -> patched 4xLC to -> LC Server
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    SM-30124-11
    ...    AND    Set Test Variable    ${work_order}    SM-30124-11
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Add New Building    ${building_name}    
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
                
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
    
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME_1}
    ${tree_node_rack_1}    Set Variable    ${tree_node_room}/${ZONE}:${POSITION_1} ${RACK_NAME_1}
    ${tree_node_switch}    Set Variable    ${tree_node_rack_1}/${SWITCH_NAME}
    ${tree_node_server}    Set Variable    ${tree_node_rack_1}/${SERVER_NAME}    
    ${tree_node_panel_1}    Set Variable    ${tree_node_rack_1}/${PANEL_NAME_1}    
    ${device_information_rack_1}    Set Variable    ${ZONE}:${POSITION_1} ${RACK_NAME_1}->${ROOM_NAME_1}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${pair_list}	Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${object_position_list}    Create List    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}

	# 1. Launch and log in SM
	# 2. Add Building 01/Floor 01/Room 01/Rack 001	
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}    
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME_1}
    Add Rack    ${tree_node_room}    ${RACK_NAME_1} 
    	
	# 3. Add to Rack 001:
	# _LC Switch 01
	# _MPO Generic Panel 01
	# _LC Server 01
    Add Network Equipment    ${tree_node_rack_1}    ${SWITCH_NAME}
	Add Network Equipment Port    ${tree_node_rack_1}/${SWITCH_NAME}    name=${01}    portType=${LC}    quantity=6
	Add Generic Panel    ${tree_node_rack_1}    ${PANEL_NAME_1}    portType=${MPO}
    Add Device In Rack    ${tree_node_rack_1}    ${SERVER_NAME}
    Add Device In Rack Port    ${tree_node_server}    ${01}    portType=${LC}    quantity=6	

	# 4. Cable 6xLC EB from Panel 01/01 to Switch 01/01-06
	
    Open Cabling Window    ${tree_node_panel_1}    ${01}    
    Create Cabling    typeConnect=Connect    cableFrom=${tree_node_panel_1}/${01}    cableTo=${tree_node_switch}
    ...    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    ...    portsTo=${01},${02},${03},${04},${05},${06}
    Close Cabling Window 	
    Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOServiceCabledAvailable}    

	# 5. Patch 4xLC from Panel 01/01 to Server 01/01-04
	
    Open Patching Window    ${tree_node_panel_1}    ${01}
    Create Patching    patchFrom=${tree_node_panel_1}    patchTo=${tree_node_server}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04}    mpoTab=${MPO12}    mpoType=${Mpo12_4xLC}    mpoBranches=${1-1},${2-2},${3-3},${4-4}   createWo=${False}    clickNext=${True}	
    Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOServiceCabledInUse}	

	# 6. Select Server 01 and decommission server
	# 7. In Remove Patch Connection window:
	# _Set on option:
	# Remove all patch connections except for direct connection to the switch
	# _Set off option:
	# Delete server from the database after the work order is completed
	# 8. Continue to go to Decommission for Server 01
	# 9. Create Decommission Server job 
	
    Open Services Window    ${Decommission Server}    ${tree_node_server}
    Decommission Server    2    ${False}
    Create Work Order    ${work_order}
    Wait For Object Exist On Content Table    ${SWITCH_NAME} 
        
	# 10. Check ports status
	# _Switch 01/01-06: Available - Pending
	# _Panel 01/01: Available - Pending
	# _Server 01/01-06: Available - Pending			
	
	Click Tree Node On Site Manager    ${tree_node_switch}	
	Wait For Port Icon Exist On Content Table    ${01}    ${PortNEFDPanelCabled}
    :FOR    ${i}    IN RANGE    0    len(${port_list})
    \    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available - Pending}   ${i+1}
    
	Click Tree Node On Site Manager    ${tree_node_panel_1}
	Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOServiceCabledAvailableScheduled}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}   1		
    
    Click Tree Node On Site Manager    ${tree_node_server}
    Wait For Port Icon Exist On Content Table    ${01}    ${PortFDUncabledAvailableScheduled}
	:FOR    ${i}    IN RANGE    0    4
    \    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available - Pending}   ${i+1}
	
	# 11. Complete job above and observe port status	
	# _Switch 01/01-06: Available
	# _Server 01/01-06: Available
	# _Panel 01/01: Available
	
    Open Work Order Queue Window    
	Complete Work Order    ${work_order}
	Close Work Order Queue    	
    Wait For Port Icon Exist On Content Table    ${01}    ${PortFDUncabledAvailable}    	

    Click Tree Node On Site Manager    ${tree_node_switch}
    Wait For Port Icon Exist On Content Table    ${01}    ${PortNEFDPanelCabled}
    :FOR    ${i}    IN RANGE    0    len(${port_list})
    \    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}   ${i+1}
    
	Click Tree Node On Site Manager    ${tree_node_panel_1}
	Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOServiceCabledAvailable}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available}   1		
    
    Click Tree Node On Site Manager    ${tree_node_server}
    Wait For Port Icon Exist On Content Table    ${01}    ${PortFDUncabledAvailable}
	:FOR    ${i}    IN RANGE    0    4
    \    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}   ${i+1} 
	    
    # 12. Trace Panel 01/01 and observe the circuit
	# _Pair 1: Service box -> connected to -> Switch 01/1 [1-1] -> cabled 6xLC EB to -> Panel 01/01
	# ...
	# _Pair 6: Service box -> connected to -> Switch 01/6 [6-6] -> cabled 6xLC EB to -> Panel 01/01
	
    Open Trace Window    ${tree_node_panel_1}    ${01}
    :FOR    ${i}    IN RANGE    0    len(${pair_list})     
	\    Select View Trace Tab On Site Manager    ${pair_list}[${i}]	    
	\    Check Total Trace On Site Manager    3   
    \    Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}:    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${EMPTY}->${VLAN}:->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}] [${pair_list}[${i}]]    objectPath=${tree_node_switch}/${port_list}[${i}]    objectType=${Trace Switch}
	...    portIcon=${PortNEFDPanelCabled}    connectionType=${TRACE_LC_6X_MPO12_FRONT_BACK_EB_CABLING}    informationDevice=${port_list}[${i}]->${SWITCH_NAME}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [ /${A1}]    objectPath=${tree_node_panel_1}/${01}    objectType=${Trace Generic MPO Panel}
	...    mpoType=${12}    portIcon=${PortMPOServiceCabledAvailable}    informationDevice=${01}->${PANEL_NAME_1}->${device_information_rack_1}
    Close Cabling Window	
    
SM-30124-12_Verify that the user can decommission server with 6xLC EB: MPO24 Switch -> cabled 3xMPO to -> MPO12 -> F2B cabling 6xLC to -> LC -> patched 6xLC to -> MPO12 Server
    [Setup]    Run Keywords    Set Test Variable    ${building_name}    SM-30124-12
    ...    AND    Set Test Variable    ${work_order}    SM-30124-12
    ...    AND    Delete Building     name=${building_name}
    ...    AND    Add New Building    ${building_name}    
    ...    AND    Open SM Login Page
    ...    AND    Login To SM    ${USERNAME}    ${PASSWORD}
                
    [Teardown]    Run Keywords    Delete Building     name=${building_name}
    ...    AND    Close Browser
     
    ${tree_node_room}    Set Variable    ${SITE_NODE}/${building_name}/${FLOOR_NAME}/${ROOM_NAME_1}
    ${tree_node_rack_1}    Set Variable    ${tree_node_room}/${ZONE}:${POSITION_1} ${RACK_NAME_1}
    ${tree_node_rack_2}    Set Variable    ${tree_node_room}/${ZONE}:${POSITION_2} ${RACK_NAME_2}
    ${tree_node_switch}    Set Variable    ${tree_node_rack_1}/${SWITCH_NAME}
    ${tree_node_server}    Set Variable    ${tree_node_rack_2}/${SERVER_NAME}    
    ${tree_node_panel_1}    Set Variable    ${tree_node_rack_1}/${PANEL_NAME_1}
    ${tree_node_panel_2}    Set Variable    ${tree_node_rack_1}/${PANEL_NAME_2}
    ${device_information_rack_1}    Set Variable    ${ZONE}:${POSITION_1} ${RACK_NAME_1}->${ROOM_NAME_1}->${FLOOR_NAME}->${building_name}->${SITE_NODE}
    ${port_list}    Create List    ${01}    ${02}    ${03}    ${04}    ${05}    ${06}
    ${pair_list}	Create List    ${Pair 1}    ${Pair 2}    ${Pair 3}    ${Pair 4}    ${Pair 5}    ${Pair 6}
    ${object_position_list}    Create List    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}
                
	# 1. Launch and log in SM
	# 2. Add Building 01/Floor 01/Room 01/Rack 001    
    Add Floor    ${SITE_NODE}/${building_name}    ${FLOOR_NAME}    
    Add Room    ${SITE_NODE}/${building_name}/${FLOOR_NAME}    ${ROOM_NAME_1}
    Add Rack    ${tree_node_room}    ${RACK_NAME_1} 	

	# 3. Add to 1:1 Rack 001:
	# _MPO24 Switch 01
	# _MPO Generic Panel 01
	# _LC Generic Panel 02
	Add Network Equipment    ${tree_node_rack_1}    ${SWITCH_NAME}
	Add Network Equipment Port    ${tree_node_rack_1}/${SWITCH_NAME}    name=${01}    portType=${MPO24}    quantity=6
	Add Generic Panel    ${tree_node_rack_1}    ${PANEL_NAME_1}    portType=${MPO}
    Add Generic Panel    ${tree_node_rack_1}    ${PANEL_NAME_2}    portType=${LC}
        
	# 4. Add to 1:2 Rak 002:
	# _MPO12 Server 01
	Add Rack    treeNode=${tree_node_room}    name=${RACK_NAME_2}    position=${POSITION_2}
    Add Device In Rack    ${tree_node_rack_2}    ${SERVER_NAME}
    Add Device In Rack Port    ${tree_node_server}    ${01}    portType=${MPO12}    quantity=6	
    
	# 5. Cable 3xMPO from Switch 01/01 to Panel 01/01-03
    Open Cabling Window    ${tree_node_switch}    ${01}    
    Create Cabling    typeConnect=Connect    cableFrom=${tree_node_switch}/${01}    cableTo=${tree_node_panel_1}
    ...    mpoTab=${MPO24}    mpoType=${Mpo24_3xMpo12}    mpoBranches=${B1},${B2},${B3}
    ...    portsTo=${01},${02},${03}
    Close Cabling Window 	
    Wait For Port Icon Exist On Content Table    ${01}    ${PortNEMPOPanelCabled}

	# 6. F2B Cabling 6xLC EB from Panel 01/01 to Panel 02/01-06
    Open Front To Back Cabling Window    ${tree_node_panel_1}    ${01}
    Create Front To Back Cabling    cabFrom=${tree_node_panel_1}    cabTo=${tree_node_panel_2}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}
    Close Front To Back Cabling Window
    Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOServiceCabledInUse} 	

	# 7. Patch 6xLC EB from Server 01/01 to Panel 02/01-06 
    Open Patching Window    ${tree_node_server}    ${01}
    Create Patching    patchFrom=${tree_node_server}    patchTo=${tree_node_panel_2}
    ...    portsFrom=${01}    portsTo=${01},${02},${03},${04},${05},${06}    mpoTab=${MPO12}    mpoType=${Mpo12_6xLC_EB}    mpoBranches=${Pair 1},${Pair 2},${Pair 3},${Pair 4},${Pair 5},${Pair 6}   createWo=${False}    clickNext=${True}	
    Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOUncabledInUse}	

	# 8. Select Server 01 and decommission server
	# 9. In Remove Patch Connection window, set on:
	# _Select patch connections to retain
	# _Delete server from the database after the work order is completed
	# 10. Continue to go to Decommission for Server 01
	# 11. Create Decommission Server job 
	
    Open Services Window    ${Decommission Server}    ${tree_node_server}
    Decommission Server    3
    Remove Patching On Decommission Server Window    
    Create Work Order    ${work_order}       
    Wait For Object Exist On Content Table    ${SERVER_NAME}    

	# 12. Check ports status
	# _Switch 01/01: In Use - 1/3
	# _Panel 01/01: In Use
	# _Panel 01/02-03: Available
	# _Panel 02/01-06: Available - Pending
	# _Server 01/01: Available - Pending
	Click Tree Node On Site Manager    ${tree_node_switch} 
	Wait For Port Icon Exist On Content Table    ${01}    ${PortNEMPOPanelCabled}   
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - 1/3}   1
	
	Click Tree Node On Site Manager    ${tree_node_panel_1}	
	Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOServiceCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}   1
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${02},${Available}    2
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${03},${Available}    3		
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}
    Wait For Port Icon Exist On Content Table    ${01}    ${PortFDPanelCabledAvailableScheduled}
    Wait For Object Exist On Content Table    ${01}
    :FOR    ${i}    IN RANGE    0    len(${port_list})
    \    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available - Pending}   ${i+1}
    
    Click Tree Node On Site Manager    ${tree_node_server}
    Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOUncabledAvailableScheduled}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${Available - Pending}   1
	
	# 13. Complete job above and observe port status
	# _Switch 01/01: In Use - 1/3
	# _Panel 01/01: In Use
	# _Panel 01/02-03: Available
	# _Panel 02/01-06: Available
	# _Server 01 is removed out of Rack 002
	
    Open Work Order Queue Window    
	Complete Work Order    ${work_order}
	Close Work Order Queue    	

    Click Tree Node On Site Manager    ${tree_node_switch} 
    Wait For Port Icon Exist On Content Table    ${01}    ${PortNEMPOPanelCabled}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use - 1/3}   1
	
	Click Tree Node On Site Manager    ${tree_node_panel_1}
	Wait For Port Icon Exist On Content Table    ${01}    ${PortMPOServiceCabledInUse}
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${01},${In Use}   1
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${02},${Available}   2
	Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${03},${Available}   3		
    
    Click Tree Node On Site Manager    ${tree_node_panel_2}
    Wait For Port Icon Exist On Content Table    ${01}    ${PortFDPanelCabledAvailable}
    Wait For Object Exist On Content Table    ${01}    
    :FOR    ${i}    IN RANGE    0    len(${port_list})
    \    Check Table Row Map With Header On Content Table    ${Name},${Port Status}    ${port_list}[${i}],${Available}   ${i+1}
    
    Check Tree Node Not Exist On Site Manager    ${tree_node_server}    
	    
	# 14. Trace Panel 01/01 and observe the circuit
	# _Pair 1: Service box -> connected to -> Switch 01/24 1 [A1] -> cabled 3xMPO to -> Panel 01/12 1 [A1/B1] -> f2b cabled to ->Panel 02/1 [/Pair 1] 
	# ...
	# _Pair 4: Service box -> connected to -> Switch 01/24 1 [A1] -> cabled 3xMPO to -> Panel 01/12 1 [A1/B1] -> f2b cabled to ->Panel 02/4 [/Pair 4] 
	# _Pair 5: No Path Switch 01/24 1 [A1] -> cabled 3xMPO to -> Panel 01/12 1 [A1/B1] -> f2b cabled to ->Panel 02/5 [/Pair 5] 
	# _Pair 6: No Path Switch 01/24 1 [A1] -> cabled 3xMPO to -> Panel 01/12 1 [A1/B1] -> f2b cabled to ->Panel 02/6 [/Pair 6]
	
    Open Trace Window    ${tree_node_panel_1}    ${01}
    :FOR    ${i}    IN RANGE    0    4     
	\    Select View Trace Tab On Site Manager    ${pair_list}[${i}]	    
	\    Check Total Trace On Site Manager    4    	
	\    Check Trace Object On Site Manager    indexObject=1    objectPath=${Config}: /${VLAN}: /${Service}:    objectType=${Trace Service Object}
	...    connectionType=${Trace Assign}    informationDevice=${Service}:->${EMPTY}->${VLAN}:->${Config}:
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${1} [${A1}]    objectPath=${tree_node_switch}/${01}    objectType=${Trace Switch}
	...    portIcon=${PortNEMPOPanelCabled}    connectionType=${TRACE_MPO24_3X_MPO12_FRONT_BACK_CABLING}    informationDevice=${01}->${SWITCH_NAME}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=3    objectPosition=${1} [${A1}/${B1}]    objectPath=${tree_node_panel_1}/${01}    objectType=${Trace Generic MPO Panel}
	...    mpoType=${12}    portIcon=${PortMPOServiceCabledInUse}    connectionType=${TRACE_MPO12_6X_LC_FRONT_BACK_EB_CABLING}
	...    informationDevice=${01}->${PANEL_NAME_1}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=4    objectPosition=${object_position_list}[${i}] [ /${pair_list}[${i}]]    objectPath=${tree_node_panel_2}/${port_list}[${i}]
	...    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    portIcon=${PortFDPanelCabledAvailable}    informationDevice=${port_list}[${i}]->${PANEL_NAME_2}->${device_information_rack_1}
		
    :FOR    ${i}    IN RANGE    4    6
	\    Select View Trace Tab On Site Manager    ${pair_list}[${i}]	    
	\    Check Total Trace On Site Manager    2   		
	\    Check Trace Object On Site Manager    indexObject=1    objectPosition=${1} [${A1}]    objectPath=${tree_node_panel_1}/${01}    objectType=${Trace Generic MPO Panel}
	...    mpoType=${12}    portIcon=${Trace No Path}    connectionType=${TRACE_MPO12_6X_LC_FRONT_BACK_EB_CABLING}
	...    informationDevice=${No Path}->${PANEL_NAME_1}->${device_information_rack_1}
	\    Check Trace Object On Site Manager    indexObject=2    objectPosition=${object_position_list}[${i}] [ /${pair_list}[${i}]]    objectPath=${tree_node_panel_2}/${port_list}[${i}]
	...    objectType=${TRACE_GENERIC_FIBER_PANEL_IMAGE}    portIcon=${PortFDPanelCabledAvailable}    informationDevice=${port_list}[${i}]->${PANEL_NAME_2}->${device_information_rack_1}
	Close Trace Window 	 
