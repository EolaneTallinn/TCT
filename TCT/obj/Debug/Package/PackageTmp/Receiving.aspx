<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Receiving.aspx.cs" Inherits="TCT.Receiving" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/jscript" language="javascript">
        function CalcLC(Qty, TotalPrice, ExchRate, TotalPriceInLC, LocalCurrency, UnitPrice) {
            T = TotalPrice.value.replace(",", ".") * ExchRate.value.replace(",", ".");
            U = T / Qty.value.replace(",", ".");
            if (isNaN(T*U) || !isFinite(T*U)) { return; }
            TotalPriceInLC.value = T.toString().replace(".", ",");
            LocalCurrency.value = "EUR";
            UnitPrice.value = U.toString().replace(".", ",");
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <table style="width: 100%; vertical-align: top;">
    <tr>
        <td style="width: 280px; vertical-align: top;">
            Filter: <asp:DropDownList ID="FBFilterDropDownList" runat="server" CssClass="grey" 
                onselectedindexchanged="FBFilterDropDownList_SelectedIndexChanged" AutoPostBack="True">
                <asp:ListItem Value="1">New AWB</asp:ListItem>
                <asp:ListItem Value="2">Unmatched AWB</asp:ListItem>
                <asp:ListItem Value="3">PUCC</asp:ListItem>
                <asp:ListItem Value="4">non-PUCC</asp:ListItem>
                </asp:DropDownList>
            <br /><br />
            Search: <asp:TextBox ID="SearchTextBox" runat="server" onkeyup="myfilter.set(this.value)" CssClass="grey" Width="150px"/>
            <img src="Images/search.png" alt="Just type in the search field" />
            <br /><br />
            <b>Freight Bill Number ... (Items)</b><br />
            <asp:ListBox ID="ListBoxFreightBills" runat="server" DataSourceID="SqlDataSource_FreightBills_1" 
                DataTextField="fbnum" DataValueField="FreightBillNumber" Height="450px" Width="250px" 
                AutoPostBack="True" OnSelectedIndexChanged="ListBoxFreightBills_SelectedIndexChanged">
            </asp:ListBox><br />
            <asp:CheckBox ID="ShowT1CheckBox" runat="server" Text="Show non-transit also" AutoPostBack="True" visible="false" OnCheckedChanged="ShowT1CheckBox_CheckedChanged"/>
            <asp:SqlDataSource ID="SqlDataSource_FreightBills_1" runat="server" ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT DISTINCT dl.FreightBillNumber, dl.FreightBillNumber + ' ... (' + CAST(count(dl.FreightBillNumber) as varchar) + ')' fbnum 
                    FROM Delivery.DeliveryLine dl INNER JOIN PurchaseOrder.PurchaseOrder po ON dl.FreightBillNumber=po.FreightBillNumber 
                    INNER JOIN Delivery.DeliveryHeader dh ON dl.DeliveryID=dh.DeliveryID WHERE po.IsFinished='False' and dh.T1Number is not null GROUP BY dl.FreightBillNumber">
            </asp:SqlDataSource>
            <asp:SqlDataSource ID="SqlDataSource_FreightBills_2" runat="server" ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT DISTINCT dl.FreightBillNumber, dl.FreightBillNumber fbnum 
                    FROM Delivery.DeliveryLine dl LEFT JOIN PurchaseOrder.PurchaseOrder po ON dl.FreightBillNumber = po.FreightBillNumber 
                    INNER JOIN Delivery.DeliveryHeader dh ON dl.DeliveryID = dh.DeliveryID WHERE po.FreightBillNumber IS NULL AND dh.T1Number IS NOT NULL">
            </asp:SqlDataSource>
            <asp:SqlDataSource ID="SqlDataSource_FreightBills_2b" runat="server" ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT DISTINCT dl.FreightBillNumber, dl.FreightBillNumber fbnum 
                    FROM Delivery.DeliveryLine dl LEFT JOIN PurchaseOrder.PurchaseOrder po ON dl.FreightBillNumber = po.FreightBillNumber 
                    INNER JOIN Delivery.DeliveryHeader dh ON dl.DeliveryID = dh.DeliveryID WHERE po.FreightBillNumber IS NULL">
            </asp:SqlDataSource>
            <asp:SqlDataSource ID="SqlDataSource_FreightBills_3" runat="server" ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT FreightBillNumber, FreightBillNumber + ' ... (' + CAST(count(FreightBillNumber) as varchar) + ')' fbnum 
                    FROM PurchaseOrder.PurchaseOrder WHERE IsCustomHandled='True' AND IsFinished='True' GROUP BY FreightBillNumber">
            </asp:SqlDataSource>
            <asp:SqlDataSource ID="SqlDataSource_FreightBills_4" runat="server" ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT FreightBillNumber, FreightBillNumber + ' ... (' + CAST(count(FreightBillNumber) as varchar) + ')' fbnum 
                    FROM PurchaseOrder.PurchaseOrder WHERE IsCustomHandled='False' AND IsFinished='True' GROUP BY FreightBillNumber">
            </asp:SqlDataSource>
        </td>
        <td style="vertical-align: top;">

            <asp:PlaceHolder ID="PlaceHolderFreightBills" runat="server" Visible="False">
                <span style="background-color:#507CD1; color:white; padding:5px;">
                    <b>Freight Bill (AWB): <asp:Label ID="FreightBillNumberLabel" runat="server" BackColor="#507CD1" ForeColor="#99ff99" /></b>
                </span>

                <asp:GridView ID="GridViewPOLines" runat="server" AutoGenerateColumns="False" CellPadding="4" DataKeyNames="PurchaseOrderLineID" 
                    DataSourceID="SqlDataSource_POLines_1" ForeColor="#333333" GridLines="None" 
                    OnSelectedIndexChanged="GridViewPOLines_SelectedIndexChanged" OnRowDataBound="GridViewPOLines_RowDataBound">
                    <AlternatingRowStyle BackColor="White" />
                    <Columns>
                        <asp:BoundField DataField="ItemID" HeaderText="Item" />
                        <asp:BoundField DataField="DeliveredQuantity" HeaderText="Quantity" />
                        <asp:BoundField DataField="po" HeaderText="PO Number/Line" />
                        <asp:BoundField DataField="DeclarationNumber" HeaderText="Decl. Nr" />
                        <asp:BoundField DataField="DeclarationDate" HeaderText="Decl. Date" DataFormatString="{0:dd.MM.yyyy}" />
                        <asp:BoundField DataField="Amount" HeaderText="Total Price" DataFormatString="{0:F2}" />
                        <asp:BoundField DataField="DocumentCurrency" HeaderText="Currency" />
                        <asp:BoundField DataField="CustomsCode" HeaderText="Customs Code" />
                        <asp:BoundField DataField="CountryOfOrigin" HeaderText="Country Of Origin" />
                        <asp:BoundField DataField="InvoiceNumber" HeaderText="Invoice No." />
                    </Columns>
                    <FooterStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
                    <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
                    <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
                    <RowStyle BackColor="#EFF3FB" />
                    <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" />
                </asp:GridView>

                <asp:SqlDataSource ID="SqlDataSource_POLines_1" runat="server" 
                    ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                    SelectCommand="SELECT PurchaseOrderLineID, ItemID, DeliveredQuantity, PONumber + '/' + POLineNumber AS po, 
                        DeclarationNumber, DeclarationDate, Amount, DocumentCurrency, CustomsCode, CountryOfOrigin, InvoiceNumber 
                        FROM PurchaseOrder.PurchaseOrder
                        WHERE FreightBillNumber = @FreightBillNumber AND IsFinished='False'">
                    <SelectParameters>
                        <asp:ControlParameter Name="FreightBillNumber" ControlID="ListBoxFreightBills" PropertyName="SelectedValue" />
                    </SelectParameters>
                </asp:SqlDataSource>
                <asp:SqlDataSource ID="SqlDataSource_POLines_3" runat="server" 
                    ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                    SelectCommand="SELECT PurchaseOrderLineID, ItemID, DeliveredQuantity, PONumber + '/' + POLineNumber AS po, 
                        DeclarationNumber, DeclarationDate, Amount, DocumentCurrency, CustomsCode, CountryOfOrigin, InvoiceNumber 
                        FROM PurchaseOrder.PurchaseOrder
                        WHERE FreightBillNumber = @FreightBillNumber AND IsCustomHandled='True' AND IsFinished='True'">
                    <SelectParameters>
                        <asp:ControlParameter Name="FreightBillNumber" ControlID="ListBoxFreightBills" PropertyName="SelectedValue" />
                    </SelectParameters>
                </asp:SqlDataSource>
                <asp:SqlDataSource ID="SqlDataSource_POLines_4" runat="server" 
                    ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                    SelectCommand="SELECT PurchaseOrderLineID, ItemID, DeliveredQuantity, PONumber + '/' + POLineNumber AS po, 
                        DeclarationNumber, DeclarationDate, Amount, DocumentCurrency, CustomsCode, CountryOfOrigin, InvoiceNumber 
                        FROM PurchaseOrder.PurchaseOrder
                        WHERE FreightBillNumber = @FreightBillNumber AND IsCustomHandled='False' AND IsFinished='True'">
                    <SelectParameters>
                        <asp:ControlParameter Name="FreightBillNumber" ControlID="ListBoxFreightBills" PropertyName="SelectedValue" />
                    </SelectParameters>
                </asp:SqlDataSource>

            </asp:PlaceHolder>

            <asp:PlaceHolder ID="PlaceHolderUnmatchedFreightBills" runat="server" Visible="False">
                <h3>Unmatched Freight Bill:</h3>
                <img src="Images/warning.jpg" align="middle" alt="" /> Freight Bill 
                <asp:Label ID="UnmatchedFBNumberLabel" runat="server" Font-Bold="True"><%= ListBoxFreightBills.SelectedValue %></asp:Label> was not found in SAP.<br /><br />
                Possible reasons:<br />
                1) FB number in Gate Registration is incorrect. Please check <asp:LinkButton ID="UnmatchedFBLinkButton" runat="server" Text="Gate Registration" PostBackUrl = "~/GateReg.aspx"/><br />
                2) FB number in SAP is incorrect. Please check SAP Purhase Order / Goods Receipt.<br />
                3) SAP Goods Receipt info hasn't arrived to TCT yet. Please wait until tomorrow, or use below simulation.<br />
                <br />
                <br />
                <b>Simulate SAP Goods Receipt:</b><br />
                You could also simulate the SAP goods receiving process for TCT<br />
                <br />
                <asp:FormView ID="FormViewNewPOLine" runat="server" DataSourceID="SqlDataSource_POLine" DefaultMode="Insert">
                    <InsertItemTemplate>
                        <table style="width: 100%;">
                            <tr><td>Freight Bill:</td>
                                <td><asp:TextBox ID="FreightBillNumberTextBox" runat="server" Text='<%# Bind("FreightBillNumber") %>' CssClass="grey" />
                                    <asp:RequiredFieldValidator ID="ReqFieldValidatorFreightBillNumber" runat="server" ErrorMessage="* Required field"
                                        ControlToValidate="FreightBillNumberTextBox" ValidationGroup="InsertPOLine" CssClass="red" Display="Dynamic" />
                                    <asp:Label ID="FreightBillNumberLabel" runat="server" Font-Bold="True"><%= ListBoxFreightBills.SelectedValue %></asp:Label>
                                </td>
                            </tr>
                            <tr><td>PONumber:</td>
                                <td><asp:TextBox ID="PONumberTextBox" runat="server" Text='<%# Bind("PONumber") %>' CssClass="grey" />
                                    <asp:RequiredFieldValidator ID="ReqFieldValidatorPONumber" runat="server" ErrorMessage="* Required field"
                                        ControlToValidate="PONumberTextBox" ValidationGroup="InsertPOLine" CssClass="red" Display="Dynamic" />
                                </td>
                            </tr>

                            <tr><td>POLineNumber:</td>
                                <td><asp:TextBox ID="POLineNumberTextBox" runat="server" Text='<%# Bind("POLineNumber") %>' CssClass="grey" />
                                    <asp:RequiredFieldValidator ID="ReqFieldValidatorPOLineNumber" runat="server" ErrorMessage="* Required field"
                                        ControlToValidate="POLineNumberTextBox" ValidationGroup="InsertPOLine" CssClass="red" Display="Dynamic" />
                                </td>
                            </tr>

                            <tr><td>Item Code:</td>
                                <td><asp:TextBox ID="ItemIDTextBox" runat="server" Text='<%# Bind("ItemID") %>' CssClass="grey" />
                                    <asp:RequiredFieldValidator ID="ReqFieldValidatorItemID" runat="server" ErrorMessage="* Required field"
                                        ControlToValidate="ItemIDTextBox" ValidationGroup="InsertPOLine" CssClass="red" Display="Dynamic" />
                                </td>
                            </tr>
                            <tr><td>Ordered Quantity:</td>
                                <td><asp:TextBox ID="OrderedQuantityTextBox" runat="server" Text='<%# Bind("OrderedQuantity") %>' CssClass="grey" />
                                    <asp:RegularExpressionValidator ID="RegExValidatorOrderedQuantity" runat="server" ErrorMessage="* Please insert a number"
                                        ControlToValidate="OrderedQuantityTextBox" ValidationGroup="InsertPOLine" CssClass="red" Display="Dynamic" ValidationExpression="^\d+$" />
                                </td>
                            </tr>
                            <tr><td>Received Quantity:</td>
                                <td><asp:TextBox ID="DeliveredQuantityTextBox" runat="server" Text='<%# Bind("DeliveredQuantity") %>' CssClass="grey" />
                                    <asp:RequiredFieldValidator ID="ReqFieldValidatorDeliveredQuantity" runat="server" ErrorMessage="* Required field"
                                        ControlToValidate="DeliveredQuantityTextBox" ValidationGroup="InsertPOLine" CssClass="red" Display="Dynamic" />
                                    <asp:RegularExpressionValidator ID="RegExValidatorDeliveredQuantity" runat="server" ErrorMessage="* Please insert a number"
                                        ControlToValidate="DeliveredQuantityTextBox" ValidationGroup="InsertPOLine" CssClass="red" Display="Dynamic" ValidationExpression="^\d+$" />
                                </td>
                            </tr>
                            <tr><td></td>
                                <td><asp:Button ID="POLineInsertButton" runat="server" CommandName="Insert" Text="Create SAP Goods Receipt" 
                                        CausesValidation="True" ValidationGroup="InsertPOLine" />
                                </td>
                            </tr>
                        </table>
                    </InsertItemTemplate>
                </asp:FormView>


                <%-- NEW SECTION - show similar FB numbers from PO table and allow to "fix" FB numbers --%>
                <br />
<%--
                "Similar" FreightBill numbers in SAP:
                <asp:GridView ID="GridViewSimilarFBs" runat="server" AutoGenerateColumns="False" CellPadding="4" DataKeyNames="PurchaseOrderLineID" 
                    DataSourceID="SqlDataSource_SimilarFBs" ForeColor="#333333" GridLines="None">
                    <AlternatingRowStyle BackColor="White" />
                    <Columns>
                        <asp:BoundField DataField="FreightBillNumber" HeaderText="FB in SAP" />
                        <asp:BoundField DataField="PONumber" HeaderText="PO Number" />
                        <asp:BoundField DataField="POLineNumber" HeaderText="PO Line" />
                        <asp:BoundField DataField="ItemID" HeaderText="Item ID" />
                        <asp:BoundField DataField="Description" HeaderText="Description" />
                        <asp:BoundField DataField="OrderedQuantity" HeaderText="Ordered Qty" />
                        <asp:BoundField DataField="DeliveredQuantity" HeaderText="Delivered Qty" />
                        <asp:BoundField DataField="AmountInLC" HeaderText="Total Cost" />
                        <asp:BoundField DataField="CustomsCode" HeaderText="Customs Code" />
                        <asp:BoundField DataField="PostingDate" HeaderText="Posting Date" DataFormatString="{0:dd.MM.yyyy}" />
                    </Columns>
                    <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
                    <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
                    <RowStyle BackColor="#EFF3FB" />
                </asp:GridView>
--%>
                <asp:SqlDataSource ID="SqlDataSource_SimilarFBs" runat="server" 
                    ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                    SelectCommand="SELECT PurchaseOrderLineID, FreightBillNumber, PONumber, POLineNumber, ItemID, [Description], 
                            OrderedQuantity, DeliveredQuantity, AmountInLC, CustomsCode, PostingDate
                        FROM PurchaseOrder.PurchaseOrder WHERE FreightBillNumber = RIGHT(@FreightBillNumber, LEN(@FreightBillNumber)-2) AND IsFinished = 0" 
                    UpdateCommand="UPDATE PurchaseOrder.PurchaseOrder
                        SET FreightBillNumber = @FreightBillNumber, ModifyUserID = @UserID
                        WHERE PurchaseOrderLineID = @PurchaseOrderLineID">
                    <SelectParameters>
                        <asp:ControlParameter Name="FreightBillNumber" ControlID="ListBoxFreightBills" PropertyName="SelectedValue" />
                    </SelectParameters>
                    <UpdateParameters>
                        <asp:SessionParameter Name="UserId" SessionField="UserId" />
                        <asp:Parameter Name="PurchaseOrderLineID" />
                    </UpdateParameters>
                </asp:SqlDataSource>

            </asp:PlaceHolder>

            <br />

            <asp:FormView ID="FormViewPOLine" runat="server" DataKeyNames="PurchaseOrderLineID" DataSourceID="SqlDataSource_POLine" 
                DefaultMode="Edit" OnItemUpdated="FormViewPOLine_ItemUpdated" OnDataBound="FormViewPOLine_DataBound" EnableViewState="False" >
                <ItemTemplate>
                    <table style="width: 100%;">
                        <tr><td><b>Item Number:</b></td>
                            <td><asp:Label ID="ItemIDLabel" runat="server" Text='<%# Eval("ItemID") %>' Font-Bold="True" /></td>
                        </tr>
                        <tr><td>Ordered Quantity:</td>
                            <td><asp:Label ID="OrderedQuantityLabel" runat="server" Text='<%# Eval("OrderedQuantity") %>' /></td>
                        </tr>
                        <tr><td>Received Quantity:</td>
                            <td><asp:Label ID="DeliveredQuantityLabel" runat="server" Text='<%# Eval("DeliveredQuantity") %>' /></td>
                        </tr>
                        <tr><td>Declaration Number:</td>
                            <td><asp:Label ID="DeclarationNumberLabel" runat="server" Text='<%# Eval("DeclarationNumber") %>' /></td>
                        </tr>
                        <tr><td>Declaration Date:</td>
                            <td><asp:Label ID="DeclarationDateLabel" runat="server" Text='<%# Eval("DeclarationDate", "{0:dd.MM.yyyy}") %>' /></td>
                        </tr>
                        <tr><td>Total Price:</td>
                            <td><asp:Label ID="AmountLabel" runat="server" Text='<%# Eval("Amount", "{0:F2}") %>' /></td>
                        </tr>
                        <tr><td>Currency:</td>
                            <td><asp:Label ID="Label1" runat="server" Text='<%# Eval("DocumentCurrency") %>' /></td>
                        </tr>
                        <tr><td>Exchange Rate:</td>
                            <td><asp:Label ID="ExchangeRateLabel" runat="server" Text='<%# Eval("ExchangeRate") %>' /></td>
                        </tr>
                        <tr><td>Total Price in LC:</td>
                            <td><asp:Label ID="AmountInLCLabel" runat="server" Text='<%# Eval("AmountInLC", "{0:F2}") %>' Width="100"/></td>
                        </tr>
                        <tr><td>Local Currency:</td>
                            <td><asp:Label ID="LocalCurrencyLabel" runat="server" Text='<%# Eval("LocalCurrency") %>' Width="100"/></td>
                        </tr>
                        <tr><td>Unit Price in LC:</td>
                            <td><asp:Label ID="UnitPriceInLCLabel" runat="server" Text='<%# Eval("UnitPriceInLC") %>' Width="100"/></td>
                        </tr>
                        <tr><td>Customs Code:</td>
                            <td><asp:Label ID="CustomsCodeLabel" runat="server" Text='<%# Eval("CustomsCode") %>' /></td>
                        </tr>
                        <tr><td>Country Of Origin:</td>
                            <td><asp:Label ID="CountryOfOriginLabel" runat="server" Text='<%# Eval("CountryOfOrigin") %>' /></td>
                        </tr>
                        <tr><td>Invoice Number:</td>
                            <td><asp:Label ID="InvoiceNumberLabel" runat="server" Text='<%# Eval("InvoiceNumber") %>' /></td>
                        </tr>
                        <tr><td>PUCC:</td>
                            <td><asp:CheckBox ID="PUCCCheckBox" runat="server" Enabled="false" Checked='<%# Eval("IsCustomHandled") %>' /></td>
                        </tr>
                        <tr><td>Closed:</td>
                            <td><asp:CheckBox ID="FinishedCheckBox" runat="server" Enabled="false" Checked='<%# Eval("IsFinished") %>' /></td>
                        </tr>
                        <tr><td></td>
                            <td><asp:Button ID="POLineOpenButton" runat="server" Text="Open" OnClick="POLineOpenButton_Click" Visible='<%# FBFilterDropDownList.SelectedValue.Equals("4") %>'/>
                            </td>
                        </tr>
                    </table>
                </ItemTemplate>
                <EditItemTemplate>
                    <table style="width: 100%;">
                        <tr><td><b>Item Number:</b></td>
                            <td><asp:Label ID="ItemIDLabel" runat="server" Text='<%# Eval("ItemID") %>' Font-Bold="True" />
                            </td>
                        </tr>
                        <tr><td>Ordered Quantity:</td>
                            <td><asp:Label ID="OrderedQuantityLabel" runat="server" Text='<%# Eval("OrderedQuantity") %>' />
                            </td>
                        </tr>
                        <tr><td>Received Quantity:</td>
                            <td><asp:TextBox ID="DeliveredQuantityTextBox" runat="server" Text='<%# Bind("DeliveredQuantity") %>' CssClass="grey" />
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorDeliveredQuantity" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="DeliveredQuantityTextBox" ValidationGroup="UpdatePOLine" CssClass="red" Display="Dynamic" />
                                <asp:RegularExpressionValidator ID="RegExValidatorDeliveredQuantity" runat="server" ErrorMessage="* Please insert a number"
                                    ControlToValidate="DeliveredQuantityTextBox" ValidationGroup="UpdatePOLine" CssClass="red" Display="Dynamic" ValidationExpression="^\d+$" />
                                <asp:Label ID="QuantityWarningLabel" runat="server" CssClass="yellow" Visible="false">Warning: Qty is different from Ordered qty!</asp:Label>
                            </td>
                        </tr>
                        <tr><td>Declaration Number:</td>
                            <td><asp:TextBox ID="DeclarationNumberTextBox" runat="server" Text='<%# Bind("DeclarationNumber") %>' CssClass="grey" />
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorDeclarationNumber" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="DeclarationNumberTextBox" ValidationGroup="UpdatePOLine" CssClass="red" Display="Dynamic" />
                            </td>
                        </tr>
                        <tr><td>Declaration Date:</td>
                            <td><asp:TextBox ID="DeclarationDateTextBox" runat="server" Text='<%# Bind("DeclarationDate", "{0:dd.MM.yyyy}") %>' CssClass="grey" />
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorDeclarationDate" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="DeclarationDateTextBox" ValidationGroup="UpdatePOLine" CssClass="red" Display="Dynamic" />
                                <ajax:CalendarExtender ID="DeclarationDateCalendarExtender" runat="server" TargetControlID="DeclarationDateTextBox" 
                                    FirstDayOfWeek="Monday" Format="dd.MM.yyyy">
                                </ajax:CalendarExtender>
                            </td>
                        </tr>
                        <tr><td>Total Price:</td>
                            <td><asp:TextBox ID="AmountTextBox" runat="server" Text='<%# Bind("Amount", "{0:F2}") %>' CssClass="grey" />
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorAmount" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="AmountTextBox" ValidationGroup="UpdatePOLine" CssClass="red" Display="Dynamic" />
                                <asp:RegularExpressionValidator ID="RegExValidatorAmount" runat="server" ErrorMessage="* Please insert a number"
                                    ControlToValidate="AmountTextBox" ValidationGroup="UpdatePOLine" CssClass="red" Display="Dynamic" ValidationExpression="^\d+([,.]\d+)?$" />
                            </td>
                        </tr>
                        <tr><td>Currency:</td>
                            <td><asp:DropDownList ID="DocumentCurrencyDropDownList" runat="server" DataSourceID="SqlDataSource_Currencies" CssClass="grey"
                                    DataTextField="Code2" DataValueField="Code" SelectedValue='<%# Bind("DocumentCurrency") %>' AppendDataBoundItems="True">
                                    <asp:ListItem></asp:ListItem>
                                </asp:DropDownList>
                                <asp:SqlDataSource ID="SqlDataSource_Currencies" runat="server" 
                                    ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                                    SelectCommand="SELECT Code, Code + ' (' + Name + ')' Code2 FROM PurchaseOrder.Currency">
                                </asp:SqlDataSource>
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorDocumentCurrency" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="DocumentCurrencyDropDownList" ValidationGroup="UpdatePOLine" CssClass="red" InitialValue="" />
                            </td>
                        </tr>
                        <tr><td>Exchange Rate:</td>
                            <td><asp:TextBox ID="ExchangeRateTextBox" runat="server" Text='<%# Bind("ExchangeRate") %>' CssClass="grey" />
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorExchangeRate" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="ExchangeRateTextBox" ValidationGroup="UpdatePOLine" CssClass="red" Display="Dynamic" />
                                <asp:RegularExpressionValidator ID="RegExValidatorExchangeRate" runat="server" ErrorMessage="* Please insert a number"
                                    ControlToValidate="ExchangeRateTextBox" ValidationGroup="UpdatePOLine" CssClass="red" Display="Dynamic" ValidationExpression="^\d+([,.]\d+)?$" />
                            </td>
                        </tr>
                        <tr><td>Total Price in LC:</td>
                            <td><asp:TextBox ID="AmountInLCTextBox" runat="server" Text='<%# Bind("AmountInLC", "{0:F2}") %>' CssClass="grey" Width="100" />\
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorAmountInLC" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="AmountInLCTextBox" ValidationGroup="UpdatePOLine" CssClass="red" Display="Dynamic" />
                            </td>
                        </tr>
                        <tr><td>Local Currency:</td>
                            <td><asp:TextBox ID="LocalCurrencyTextBox" runat="server" Text='<%# Bind("LocalCurrency") %>' CssClass="grey"  Width="100"/> | 
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorLocalCurrency" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="LocalCurrencyTextBox" ValidationGroup="UpdatePOLine" CssClass="red" Display="Dynamic" />
                                <asp:Button ID="CalcLCButton" runat="server" Text="<- Calculate" UseSubmitBehavior="False" /><%--Note! OnKeyUp event added to this button, check code behind--%>
                            </td>
                        </tr>
                        <tr><td>Unit Price in LC:</td>
                            <td><asp:TextBox ID="UnitPriceInLCTextBox" runat="server" Text='<%# Bind("UnitPriceInLC") %>' CssClass="grey"  Width="100"/>/
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorUnitPriceInLC" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="UnitPriceInLCTextBox" ValidationGroup="UpdatePOLine" CssClass="red" Display="Dynamic" />
                            </td>
                        </tr>
                        <tr><td>Customs Code:</td>
                            <td><asp:TextBox ID="CustomsCodeTextBox" runat="server" Text='<%# Bind("CustomsCode") %>' CssClass="grey" />
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorCustomsCode" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="CustomsCodeTextBox" ValidationGroup="UpdatePOLine" CssClass="red" Display="Dynamic" />
                                <asp:RegularExpressionValidator ID="RegExValidatorCustomsCode" runat="server" ErrorMessage="* Please insert a 10-digit number"
                                    ControlToValidate="CustomsCodeTextBox" ValidationGroup="UpdatePOLine" CssClass="red" Display="Dynamic" ValidationExpression="^\d{10}$" />
                            </td>
                        </tr>
                        <tr><td>Country Of Origin:</td>
                            <td><asp:DropDownList ID="CountryOfOriginDropDownList" runat="server" DataSourceID="SqlDataSource_Countries" CssClass="grey"
                                    DataTextField="NameAndCode" DataValueField="Code" SelectedValue='<%# Bind("CountryOfOrigin") %>' AppendDataBoundItems="True">
                                    <asp:ListItem></asp:ListItem>
                                </asp:DropDownList>
                                <asp:SqlDataSource ID="SqlDataSource_Countries" runat="server" 
                                    ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                                    SelectCommand="SELECT Code, Name + ' (' + Code + ')' AS NameAndCode FROM Delivery.Country">
                                </asp:SqlDataSource>
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorCountryOfOrigin" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="CountryOfOriginDropDownList" ValidationGroup="UpdatePOLine" CssClass="red" InitialValue="" />
                            </td>
                        </tr>
                        <tr><td>Invoice Number:</td>
                            <td><asp:TextBox ID="InvoiceNumberTextBox" runat="server" Text='<%# Bind("InvoiceNumber") %>' CssClass="grey" />
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorInvoiceNumber" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="InvoiceNumberTextBox" ValidationGroup="UpdatePOLine" CssClass="red" Display="Dynamic" />
                            </td>
                        </tr>
                        <%--
                        <tr><td>PUCC:</td>
                            <td><asp:CheckBox ID="PUCCCheckBox" runat="server" CssClass="grey" Checked='<%# Bind("IsCustomHandled") %>' />
                            </td>
                        </tr>
                        <tr><td>Closed:</td>
                            <td><asp:CheckBox ID="FinishedCheckBox" runat="server" CssClass="grey" Checked='<%# Bind("IsFinished") %>' />
                            </td>
                        </tr>
                        --%>
                        <tr><td></td>
                            <td><asp:Button ID="POLineUpdatePUCCButton" runat="server" CommandName="Update" Text="Move to PUCC" 
                                    CausesValidation="True" ValidationGroup="UpdatePOLine" OnClick="POLineUpdatePUCCButton_Click" />
                                &nbsp;
                                <asp:Button ID="POLineUpdateClosedButton" runat="server" CommandName="Update" Text="Move to non-PUCC" 
                                    CausesValidation="False" OnClick="POLineUpdateClosedButton_Click" />
                                &nbsp;
                                <asp:Button ID="POLineUpdateCancelButton" runat="server" CommandName="Cancel" Text="Cancel"
                                    CausesValidation="False" OnClick="POLineUpdateCancelButton_Click"/>
                            </td>
                        </tr>
                    </table>
                </EditItemTemplate>
            </asp:FormView>

            <asp:SqlDataSource ID="SqlDataSource_POLine" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT PurchaseOrderLineID, ItemID, OrderedQuantity, DeliveredQuantity, Amount, AmountInLC, ExchangeRate, UnitPriceInLC, LocalCurrency, DocumentCurrency, 
                        CustomsCode, InvoiceNumber, DeclarationNumber, DeclarationDate, CountryOfOrigin, IsCustomHandled, IsFinished  
                    FROM PurchaseOrder.PurchaseOrder WHERE PurchaseOrderLineID = @PurchaseOrderLineID" 
                UpdateCommand="UPDATE PurchaseOrder.PurchaseOrder SET 
                        DeliveredQuantity = @DeliveredQuantity, 
                        Amount = REPLACE(@Amount, ',', '.'), 
                        AmountInLC = REPLACE(@AmountInLC, ',', '.'), 
                        ExchangeRate = REPLACE(@ExchangeRate, ',', '.'), 
                        UnitPriceInLC = REPLACE(@UnitPriceInLC, ',', '.'), 
                        LocalCurrency = @LocalCurrency, 
                        DocumentCurrency = @DocumentCurrency, 
                        CustomsCode = @CustomsCode, 
                        InvoiceNumber = @InvoiceNumber, 
                        DeclarationNumber = @DeclarationNumber, 
                        DeclarationDate = CONVERT(datetime, @DeclarationDate, 104), 
                        CountryOfOrigin = @CountryOfOrigin, 
                        IsCustomHandled = @IsCustomHandled, 
                        IsFinished = @IsFinished,
                        ModifyUserID = @UserID 
                    WHERE PurchaseOrderLineID = @PurchaseOrderLineID"
                InsertCommand="INSERT INTO PurchaseOrder.PurchaseOrder (
                         FreightBillNumber
                        ,PONumber
                        ,POLineNumber
                        ,ItemID
                        ,[Description]
                        ,OrderedQuantity
                        ,DeliveredQuantity
                        ,PostingDate
                        ,CustomsCode
                        ,MaterialDocumentNumber
                    ) SELECT
                         @FreightBillNumber
                        ,@PONumber
                        ,@POLineNumber
                        ,@ItemID
                        ,Items.[Description]
                        ,@OrderedQuantity
                        ,@DeliveredQuantity
                        ,GETDATE()
                        ,Items.CustomsCode
                        ,'ManualTctEntry'
                    FROM Customs.Items WHERE ItemCode = @ItemID">
                <SelectParameters>
                    <asp:ControlParameter Name="PurchaseOrderLineID" ControlID="GridViewPOLines" PropertyName="SelectedValue" />
                </SelectParameters>
                <UpdateParameters>
                    <asp:Parameter Name="DeliveredQuantity" />
                    <asp:Parameter Name="Amount" />
                    <asp:Parameter Name="AmountInLC" />
                    <asp:Parameter Name="ExchangeRate" />
                    <asp:Parameter Name="UnitPriceInLC" />
                    <asp:Parameter Name="LocalCurrency" />
                    <asp:Parameter Name="DocumentCurrency" />
                    <asp:Parameter Name="CustomsCode" />
                    <asp:Parameter Name="InvoiceNumber" />
                    <asp:Parameter Name="DeclarationNumber" />
                    <asp:Parameter Name="DeclarationDate" />
                    <asp:Parameter Name="CountryOfOrigin" />
                    <asp:Parameter Name="IsCustomHandled" />
                    <asp:Parameter Name="IsFinished" />
                    <asp:SessionParameter Name="UserId" SessionField="UserId" />
                    <asp:Parameter Name="PurchaseOrderLineID" />
                </UpdateParameters>
                <InsertParameters>
                    <%-- <asp:ControlParameter Name="FreightBillNumber" ControlID="ListBoxFreightBills" PropertyName="SelectedValue" /> --%>
                    <asp:Parameter Name="FreightBillNumber" />
                    <asp:Parameter Name="PONumber" />
                    <asp:Parameter Name="POLineNumber" />
                    <asp:Parameter Name="ItemID" />
                    <asp:Parameter Name="OrderedQuantity" />
                    <asp:Parameter Name="DeliveredQuantity" />
                </InsertParameters>
            </asp:SqlDataSource>

            <asp:SqlDataSource ID="SqlDataSource_POLineCreateStock" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                UpdateCommand="Customs.spCreateStockFromPOLine" UpdateCommandType="StoredProcedure">
                <UpdateParameters>
                    <asp:ControlParameter Name="PurchaseOrderLineID" ControlID="GridViewPOLines" PropertyName="SelectedValue" Type="Int32" />
                </UpdateParameters>
            </asp:SqlDataSource>

            <asp:SqlDataSource ID="SqlDataSource_POLineOpen" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                UpdateCommand="UPDATE PurchaseOrder.PurchaseOrder SET IsFinished=0, ModifyUserId = @UserId, ModifyDate=GETDATE()
                    WHERE IsCustomHandled=0 AND IsFinished=1 AND PurchaseOrderLineID = @PurchaseOrderLineID">
                <UpdateParameters>
                    <asp:SessionParameter Name="UserId" SessionField="UserId" />
                    <asp:ControlParameter Name="PurchaseOrderLineID" ControlID="GridViewPOLines" PropertyName="SelectedValue" />
                </UpdateParameters>
            </asp:SqlDataSource>

        </td>
    </tr>
</table>
</asp:Content>
