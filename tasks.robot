*** Settings ***
Documentation       Orders robots from RobotSpareBin Industries Inc.
...                 Saves the order HTML receipt as a PDF file.
...                 Saves the screenshot of the ordered robot.
...                 Embeds the screenshot of the robot to the PDF receipt.
...                 Creates ZIP archive of the receipts and the images.

Library             RPA.Browser.Selenium
Library             RPA.HTTP
Library             RPA.Tables
Library             Collections
Library             RPA.PDF
Library             RPA.Archive
Library             RPA.Nanonets
Library             RPA.Desktop


*** Tasks ***
Orders robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=    Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Wait Until Keyword Succeeds    10x    2s    Preview the robot
        Wait Until Keyword Succeeds    10x    2s    Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
        Create a ZIP file of the receipts
    END


*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${orders}=    Read table from CSV    orders.csv
    RETURN    ${orders}

Close the annoying modal
    Click Element When Visible    css:.btn.btn-dark

Fill the form
    [Arguments]    ${row}
    Select From List By Index    head    ${row}[Head]
    IF    ${row}[Body] == 1
        Click Element    css:#id-body-1
    ELSE IF    ${row}[Body] == 2
        Click Element    css:#id-body-2
    ELSE IF    ${row}[Body] == 3
        Click Element    css:#id-body-3
    ELSE IF    ${row}[Body] == 4
        Click Element    css:#id-body-4
    ELSE IF    ${row}[Body] == 5
        Click Element    css:#id-body-5
    ELSE IF    ${row}[Body] == 6
        Click Element    css:#id-body-6
    END
    Input Text    xpath://input[@placeholder='Enter the part number for the legs']    ${row}[Legs]
    Input Text    xpath://input[@placeholder='Shipping address']    ${row}[Address]

Preview the robot
    Click Element When Visible    css:#preview
    Wait Until Element Is Visible    css:#robot-preview-image

Submit the order
    Click Element When Visible    css:#order
    Wait Until Element Is Visible    id:receipt    5

Store the receipt as a PDF file
    [Arguments]    ${order_number}
    ${receipt}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt}    ${OUTPUT_DIR}${/}recept_${order_number}.pdf
    ${filepath}=    Convert To String    ${OUTPUT_DIR}${/}recept_${order_number}.pdf
    RETURN    ${filepath}

Take a screenshot of the robot
    [Arguments]    ${order_number}
    Screenshot    css:#robot-preview-image    ${OUTPUT_DIR}${/}recept_${order_number}.PNG
    ${filepath}=    Convert To String    ${OUTPUT_DIR}${/}recept_${order_number}.PNG
    ${list}=    Create List    ${filepath}
    RETURN    ${list}

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    Add Files To Pdf    ${screenshot}    ${pdf}
    Close Pdf    ${pdf}

Go to order another robot
    Click Element When Visible    id:order-another

Create a ZIP file of the receipts
    Archive Folder With Zip    ${OUTPUT_DIR}    ouput
