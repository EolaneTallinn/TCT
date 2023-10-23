<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Notify.aspx.cs" Inherits="TCT.Notify" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/jscript" language="javascript">
        function BeforePostbackScroll() {
            document.getElementById('<%= savePosition.ClientID %>').value = document.getElementById('<%= ListBox1.ClientID %>').scrollTop;
        }
        function AfterPostScroll() {
            if (document.getElementById('<%= savePosition.ClientID %>').value.length > 0) {
                document.getElementById('<%= ListBox1.ClientID %>').scrollTop = parseInt(document.getElementById('<%= savePosition.ClientID %>').value);
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <table style="width: 100%; vertical-align: top;">
    <tr>
        <td style="width: 280px; vertical-align: top;">
            <asp:RadioButtonList ID="NotifyFilterRadioButtonList" runat="server" onselectedindexchanged="NotifyFilterRadioButtonList_SelectedIndexChanged"
                AutoPostBack="True" RepeatDirection="Horizontal">
                <asp:ListItem Value="0" Text="Waiting for delivery &nbsp; " Selected="True" />
                <asp:ListItem Value="1" Text="Notified" />
            </asp:RadioButtonList>
            <asp:Label ID="SearchLabel" runat="server" Text="Search:" meta:resourcekey="SearchLabelResource1"/>
            <asp:TextBox ID="SearchTextBox" runat="server" onkeyup="myfilter.set(this.value)" CssClass="grey" Width="130px" />
            <img src="Images/search.png" alt="Just type in the search field" />
            <asp:ImageButton ID="BtnNewNotify" runat="server" ImageUrl="~/Images/plus.jpg" 
                OnClick="BtnNewNotify_Click" ToolTip="Create a new Freight Bill (AWB) notification" />
            <br /><br />
            <asp:Label ID="ListBox1HeaderLabel" runat="server" Text="Freight Bill (AWB) notifications" Font-Bold="true" />
            <br />
            <asp:ListBox ID="ListBox1" runat="server" DataSourceID="SqlDataSource_ListBox1" DataTextField="TextCol" DataValueField="NotifyID" 
                Height="450px" Width="250px" AutoPostBack="True" onselectedindexchanged="ListBox1_SelectedIndexChanged" />
            <br />
            <input type="hidden" id="savePosition" name="savePosition" runat="server"/>
            <asp:SqlDataSource ID="SqlDataSource_ListBox1" runat="server" CancelSelectOnNullParameter="False"
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT n.NotifyID, n.FreightBillNumber + CASE IsUrgent WHEN 1 THEN ' - URGENT!' ELSE '' END as TextCol 
                    FROM Delivery.Notify n 
                    WHERE ((@ShowDelivered = 0 AND n.DeliveryLineID IS NULL)  OR  (@ShowDelivered = 1 AND n.DeliveryLineID IS NOT NULL))
                    ORDER BY n.FreightBillNumber">
                <SelectParameters>
                    <asp:ControlParameter Name="ShowDelivered" ControlID="NotifyFilterRadioButtonList" PropertyName="SelectedValue" />
                </SelectParameters>
            </asp:SqlDataSource>

        </td>
        <td style="vertical-align: top;">

            <asp:FormView ID="FormViewNotify" runat="server" DefaultMode="Edit" 
                DataKeyNames="NotifyID" DataSourceID="SqlDataSource_FormViewNotify" 
                OnItemInserted="FormViewNotify_ItemInserted" OnItemUpdated="FormViewNotify_ItemUpdated">
                <EditItemTemplate>
                    <table style="width: 100%;">
                        <tr><td><asp:Label ID="NotifyCreateDateLabel" runat="server" Text="Notif. created:" /></td>
                            <td><asp:Label ID="CreateDateLabel" runat="server" Text='<%# Bind("CreateDate") %>' /> &nbsp;&nbsp;
                                <asp:Label ID="CreateUserLabel" runat="server" Text='<%# Bind("FullName") %>' CssClass="comment" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="NotifyFreightBillLabel" runat="server" Text="Freight Bill (AWB):" /></td>
                            <td><asp:TextBox ID="FreightBillNumberTextBox" runat="server" Text='<%# Bind("FreightBillNumber") %>' CssClass="grey" />
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorFreightBill" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="FreightBillNumberTextBox" ValidationGroup="UpdateNotify" CssClass="red" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="NotifyIsDeliveredLabel" runat="server" Text="AWB delivered:" /></td>
                            <td><asp:Label ID="IsDeliveredLabel" runat="server" Text='<%# Bind("IsDelivered") %>' />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="NotifyDeliveryIDLabel" runat="server" Text="Gate Registration:" /></td>
                            <td><asp:Label ID="DeliveryIDLabel" runat="server" Text='<%# Bind("DeliveryID") %>' />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="NotifyUrgentLabel" runat="server" Text="Urgent:" /></td>
                            <td><asp:CheckBox ID="UrgentCheckBox" runat="server" Checked='<%# Bind("IsUrgent") %>' />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="NotifySupplierLabel" runat="server" Text="Supplier:" /></td>
                            <td><asp:DropDownList ID="SupplierDropDownList" runat="server" DataSourceID="SqlDataSource_Suppliers" CssClass="grey"
                                    DataTextField="Name" DataValueField="SupplierID" SelectedValue='<%# Bind("SupplierID") %>' >
                                </asp:DropDownList>
                                <asp:SqlDataSource ID="SqlDataSource_Suppliers" runat="server" ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                                    SelectCommand="SELECT SupplierID, Name FROM Delivery.Supplier ORDER BY Name">
                                </asp:SqlDataSource>
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="NotifyETALabel" runat="server" Text="Estimated Delivery:" /></td>
                            <td><asp:TextBox ID="ETATextBox" runat="server" Text='<%# Bind("ETA", "{0:dd.MM.yyyy}") %>' CssClass="grey" />
                                <ajax:CalendarExtender ID="NotifyDateCalendarExtender" runat="server" TargetControlID="ETATextBox" 
                                    FirstDayOfWeek="Monday" Format="dd.MM.yyyy">
                                </ajax:CalendarExtender>
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="NotifyCommentLabel" runat="server" Text="Comment:" /></td>
                            <td><asp:TextBox ID="CommentTextBox" runat="server" Text='<%# Bind("Comment") %>' TextMode="multiline" Columns="50" Rows="5" CssClass="grey" />
                            </td>
                        </tr>
                        <tr><td></td>
                            <td><asp:Button ID="NotifyUpdateButton" runat="server" CommandName="Update" Text="Update" 
                                    ValidationGroup="UpdateNotify" />
                            </td>
                        </tr>
                    </table>
                </EditItemTemplate>
                <InsertItemTemplate>
                    <h3><asp:Label ID="CreateNewNotifyLabel" runat="server" Text="Create a new AWB notification:" /></h3>
                    <table style="width: 100%;">
                        <tr><td><asp:Label ID="NotifyFreightBillLabel" runat="server" Text="Freight Bill (AWB):" /></td>
                            <td><asp:TextBox ID="FreightBillNumberTextBox" runat="server" Text='<%# Bind("FreightBillNumber") %>' CssClass="grey" />
                                <asp:RequiredFieldValidator ID="ReqFieldValidatorFreightBill" runat="server" ErrorMessage="* Required field"
                                    ControlToValidate="FreightBillNumberTextBox" ValidationGroup="InsertNotify" CssClass="red" Display="Dynamic" />
                                <asp:CustomValidator ID="CustomValidatorFreightBill" runat="server" ErrorMessage="* A notification for this AWB already exists"
                                    ControlToValidate="FreightBillNumberTextBox" OnServerValidate="CustomValidatorFreightBill_ServerValidate" ValidationGroup="InsertNotify" CssClass="red" />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="NotifyUrgentLabel" runat="server" Text="Urgent:" /></td>
                            <td><asp:CheckBox ID="UrgentCheckBox" runat="server" Checked='<%# Bind("IsUrgent") %>' />
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="NotifySupplierLabel" runat="server" Text="Supplier:" /></td>
                            <td><asp:DropDownList ID="SupplierDropDownList" runat="server" DataSourceID="SqlDataSource_Suppliers" CssClass="grey"
                                    DataTextField="Name" DataValueField="SupplierID" SelectedValue='<%# Bind("SupplierID") %>' >
                                </asp:DropDownList>
                                <asp:SqlDataSource ID="SqlDataSource_Suppliers" runat="server" ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                                    SelectCommand="SELECT SupplierID, Name FROM Delivery.Supplier ORDER BY Name">
                                </asp:SqlDataSource>
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="NotifyETALabel" runat="server" Text="Estimated Delivery:" /></td>
                            <td><asp:TextBox ID="ETATextBox" runat="server" Text='<%# Bind("ETA") %>' CssClass="grey" />
                                <ajax:CalendarExtender ID="NotifyDateCalendarExtender" runat="server" TargetControlID="ETATextBox" 
                                    FirstDayOfWeek="Monday" Format="dd.MM.yyyy">
                                </ajax:CalendarExtender>
                            </td>
                        </tr>
                        <tr><td><asp:Label ID="NotifyCommentLabel" runat="server" Text="Comment:" /></td>
                            <td><asp:TextBox ID="CommentTextBox" runat="server" Text='<%# Bind("Comment") %>' TextMode="multiline" Columns="50" Rows="5" CssClass="grey" />
                            </td>
                        </tr>
                        <tr><td></td>
                            <td><asp:Button ID="NewNotifyInsertButton" runat="server" CommandName="Insert" Text="Create" 
                                    ValidationGroup="InsertNotify" />
                                &nbsp;
                                <asp:Button ID="InsertCancelButton" runat="server" CommandName="Cancel" Text="Cancel" />
                            </td>
                        </tr>
                    </table>
                </InsertItemTemplate>
            </asp:FormView>

            <asp:SqlDataSource ID="SqlDataSource_FormViewNotify" runat="server" 
                ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                SelectCommand="SELECT n.NotifyID, CASE WHEN d.DeliveryID IS NULL THEN 'No' ELSE 'Yes' END as IsDelivered, d.DeliveryID, n.FreightBillNumber, n.IsUrgent, n.SupplierID, n.ETA, n.Comment, n.CreateDate, u.FullName
                    FROM Delivery.Notify n
                        LEFT JOIN Delivery.DeliveryLine d ON n.DeliveryLineID = d.DeliveryLineID
                        LEFT JOIN Usr.[User] u ON n.CreateUserID = u.UserID
                    WHERE (NotifyID = @NotifyID)" 
                UpdateCommand="UPDATE Delivery.Notify SET FreightBillNumber = @FreightBillNumber, IsUrgent = @IsUrgent, SupplierID = @SupplierID, ETA = CONVERT(datetime, @ETA, 104), Comment = @Comment WHERE (NotifyID = @NotifyID)"
                InsertCommand="INSERT INTO Delivery.Notify(FreightBillNumber, IsUrgent, SupplierID, ETA, Comment, CreateUserID) VALUES (@FreightBillNumber, @IsUrgent, @SupplierID, CONVERT(datetime, @ETA, 104), @Comment, @UserId);
                                SELECT @NotifyID = SCOPE_IDENTITY()"
                OnInserted="SqlDataSource_FormViewNotify_Inserted">
                <SelectParameters>
                    <asp:ControlParameter Name="NotifyID" ControlID="ListBox1" PropertyName="SelectedValue" />
                </SelectParameters>
                <UpdateParameters>
                    <asp:Parameter Name="FreightBillNumber" />
                    <asp:Parameter Name="IsUrgent" />
                    <asp:Parameter Name="SupplierID" />
                    <asp:Parameter Name="ETA" />
                    <asp:Parameter Name="Comment" />
                    <asp:Parameter Name="NotifyID" />
                </UpdateParameters>
                <InsertParameters>
                    <asp:Parameter Name="FreightBillNumber" />
                    <asp:Parameter Name="IsUrgent" />
                    <asp:Parameter Name="SupplierID" />
                    <asp:Parameter Name="ETA" />
                    <asp:Parameter Name="Comment" />
                    <asp:SessionParameter Name="UserId" SessionField="UserId" />
                    <asp:Parameter Name="NotifyID" Direction="Output" Type="Int32" />
                </InsertParameters>
            </asp:SqlDataSource>

            <asp:PlaceHolder ID="PlaceHolderContacts" runat="server" Visible="false">
                <br />
                <h3><asp:Label ID="NotifyContactsLabel" runat="server" Text="Notification e-mails for this AWB:" /></h3>

                <asp:GridView ID="GridViewNotifyContacts" runat="server" AutoGenerateColumns="False" CellPadding="4" ForeColor="#333333" 
                    DataSourceID="SqlDataSource_NotifyContacts" DataKeyNames="ContactID" GridLines="None" EnablePersistedSelection="True" OnRowDataBound="GridViewNotifyContacts_RowDataBound">
                    <AlternatingRowStyle BackColor="White" />
                    <Columns>
                        <asp:BoundField DataField="FullName" HeaderText="Name" />
                        <asp:BoundField DataField="Email" HeaderText="E-mail" />
                        <asp:BoundField DataField="IsSent" HeaderText="E-mail sent" />
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:LinkButton ID="RemoveContactButton" runat="server" CommandName="delete" Text="X"
                                    ControlStyle-ForeColor="Red" ControlStyle-Font-Bold="true" ControlStyle-Font-Underline="false"
                                    OnClientClick="if (!window.confirm('Remove contact from this notification list?')) return false;" />
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EditRowStyle BackColor="#2461BF" />
                    <HeaderStyle BackColor="#507CD1" Font-Bold="True" ForeColor="White" />
                    <RowStyle BackColor="#EFF3FB" />
                    <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="True" ForeColor="#333333" />
                </asp:GridView>

                <asp:SqlDataSource ID="SqlDataSource_NotifyContacts" runat="server" 
                    ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                    SelectCommand="SELECT nc.NotifyID, nc.ContactID, CASE nc.IsSent WHEN 1 THEN 'Yes' ELSE 'No' END as IsSent, c.FullName, c.Email 
                        FROM Delivery.NotifyContacts nc
                        INNER JOIN Usr.Contacts c ON nc.ContactID = c.ContactID 
                        WHERE nc.NotifyID = @NotifyID"
                    DeleteCommand="DELETE FROM Delivery.NotifyContacts WHERE NotifyID = @NotifyID AND ContactID = @ContactID"
                    OnDeleted="SqlDataSource_NotifyContacts_Deleted">
                    <SelectParameters>
                        <asp:ControlParameter Name="NotifyID" ControlID="ListBox1" PropertyName="SelectedValue" />
                    </SelectParameters>
                    <DeleteParameters>
                        <asp:ControlParameter Name="NotifyID" ControlID="ListBox1" PropertyName="SelectedValue" />
                        <asp:Parameter Name="ContactID" />
                    </DeleteParameters>
                </asp:SqlDataSource>


                <asp:PlaceHolder ID="PlaceHolderAddContact" runat="server" Visible="false">

                    <br />
                    <asp:DropDownList ID="AddContactDropDownList" runat="server" CssClass="grey" AutoPostBack="false"
                        DataSourceID="SqlDataSource_AddContact" DataTextField="FullName" DataValueField="ContactID" />
                    <asp:SqlDataSource ID="SqlDataSource_AddContact" runat="server" CancelSelectOnNullParameter="false"
                        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
                        SelectCommand="SELECT c.ContactID, c.FullName
                            FROM Usr.Contacts c
                            LEFT JOIN Delivery.NotifyContacts nc ON c.ContactID = nc.ContactID AND nc.NotifyID = @NotifyID
                            WHERE nc.ContactID IS NULL
                            ORDER BY c.FullName"
                        InsertCommand="INSERT INTO Delivery.NotifyContacts (NotifyID, ContactID) VALUES (@NotifyID, @ContactID)">
                        <SelectParameters>
                            <asp:ControlParameter Name="NotifyID" ControlID="ListBox1" PropertyName="SelectedValue" />
                        </SelectParameters>
                        <InsertParameters>
                            <asp:ControlParameter Name="NotifyID" ControlID="ListBox1" PropertyName="SelectedValue" />
                            <asp:ControlParameter Name="ContactID" ControlID="AddContactDropDownList" PropertyName="SelectedValue" />
                        </InsertParameters>
                    </asp:SqlDataSource>

                    <asp:Button ID="AddContactButton" runat="server" Text="Add Contact" OnClick="AddContactButton_Click"/>

                </asp:PlaceHolder>

            </asp:PlaceHolder>

        </td>
    </tr>
</table>
</asp:Content>
