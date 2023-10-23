<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SetUsers.aspx.cs" Inherits="TCT.SetUsers" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    Name: <asp:TextBox ID="NewUserNameTextBox" runat="server" Width="200" CssClass="grey"/>
    Username: <asp:TextBox ID="NewUserWindowsAccountTextBox" runat="server" Width="100" CssClass="grey"/>
    <asp:Button ID="NewUserButton" runat="server" Text="Create New User" OnClick="NewUserButton_Click"/>
        
    <asp:GridView ID="GridViewUser" runat="server" AutoGenerateColumns="False" CellPadding="4" ForeColor="#333333" GridLines="None" 
        DataKeyNames="UserID" DataSourceID="SqlDataSource_User" OnRowEditing="GridViewUser_RowEditing">
        <AlternatingRowStyle BackColor="White" />
        <Columns>
            <asp:CommandField ButtonType="Button" ShowEditButton="true" />
            <asp:BoundField DataField="FullName" HeaderText="Name" />
            <asp:BoundField DataField="WindowsAccountName" HeaderText="Username" />
            <asp:TemplateField HeaderText="Language">
                <ItemTemplate>
                    <asp:Label id="LanguageLabel" runat="server" Text='<%# Bind("Language") %>' />
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:DropDownList ID="LanguageDropDownList" runat="server" SelectedValue='<%# Bind("Language") %>'>
                        <asp:ListItem Value="en" Text="English" />
                        <asp:ListItem Value="et" Text="Estonian" />
                        <asp:ListItem Value="ru" Text="Russian" />
                    </asp:DropDownList>
                </EditItemTemplate>
            </asp:TemplateField>
            <asp:CheckBoxField DataField="IsEnabled" HeaderText="Enabled" />
            <asp:BoundField DataField="LastLoginDate" HeaderText="Last Login" ReadOnly="true" />
            <asp:TemplateField>
                <EditItemTemplate>
                    </td></tr><tr><td></td><td colspan="100%">

                    <asp:GridView ID="GridViewUserRoles" runat="server" AutoGenerateColumns="False" CellPadding="4" ForeColor="#333333" GridLines="None" 
                        DataKeyNames="RoleID" DataSourceID="SqlDataSource_UserRoles">
                        <AlternatingRowStyle BackColor="White" />
                        <Columns>
                            <asp:TemplateField>
                                <ItemTemplate>
                                    <asp:CheckBox ID="UserRoleCheckBox" runat="server" Checked='<%# !Eval("UserID").ToString().Length.Equals(0) %>' OnCheckedChanged="UserRoleCheckBox_CheckedChanged" />
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="RoleName" HeaderText="Access Role" ReadOnly="true" />
                            <asp:BoundField DataField="Description" HeaderText="Description" ReadOnly="true" ItemStyle-ForeColor="Gray" />
                        </Columns>
                        <HeaderStyle BackColor="#907CD1" Font-Bold="true" ForeColor="White" />
                        <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
                        <RowStyle BackColor="#EFF3FB" />
                    </asp:GridView>

                    <hr />
                </EditItemTemplate>
            </asp:TemplateField>
        </Columns>
        <HeaderStyle BackColor="#507CD1" Font-Bold="true" ForeColor="White" />
        <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
        <RowStyle BackColor="#EFF3FB" />
        <EditRowStyle BackColor="#D1DDF1" Font-Bold="true" ForeColor="#333333" />
        <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="true" ForeColor="#FF3333" />
    </asp:GridView>

    <br />
    <asp:Label ID="AccessChangingHistoryLabel" runat="server" ForeColor="Gray" />

    <asp:SqlDataSource ID="SqlDataSource_User" runat="server" 
        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
        SelectCommand="SELECT u.UserID, u.FullName, u.WindowsAccountName, u.IsEnabled, u.LastLoginDate, u.Language
            FROM Usr.[User] u
            ORDER BY u.IsEnabled DESC, u.FullName" 
        InsertCommand="INSERT INTO Usr.[User] (FullName, WindowsAccountName) VALUES (@FullName, @WindowsAccountName)"
        UpdateCommand="UPDATE Usr.[User] SET FullName = @FullName, WindowsAccountName = @WindowsAccountName, IsEnabled = @IsEnabled, Language = @Language WHERE UserID = @UserID">
        <%--
            LEFT JOIN Usr.User_Role ur ON u.UserID = ur.UserID

		SELECT STUFF((
			SELECT ',' + CAST(b.DL_DR_SERIAL_NUMBER as varchar) FROM [dbo].[WmsDeliveryLine] b
			WHERE b.[NumberOfUniqueShipments] > 1 FOR xml path('')
		),1,1,'')

        --%>
        <InsertParameters>
            <asp:ControlParameter Name="FullName" ControlID="NewUserNameTextBox" PropertyName="Text" />
            <asp:ControlParameter Name="WindowsAccountName" ControlID="NewUserWindowsAccountTextBox" PropertyName="Text" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="FullName" />
            <asp:Parameter Name="WindowsAccountName" />
            <asp:Parameter Name="IsEnabled" />
            <asp:Parameter Name="Language" />
            <asp:Parameter Name="UserID" />
        </UpdateParameters>
    </asp:SqlDataSource>

    <asp:SqlDataSource ID="SqlDataSource_UserRoles" runat="server" 
        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
        SelectCommand="SELECT ur.UserID, r.RoleID, r.RoleName, r.Description
            FROM Usr.Role r
            LEFT JOIN (SELECT UserID, RoleID FROM Usr.User_Role WHERE UserID = @UserID) ur
                ON ur.RoleID = r.RoleID
            ORDER BY RoleID"
        InsertCommand="INSERT INTO Usr.User_Role (UserID, RoleID) VALUES (@UserID, @RoleID)" 
        DeleteCommand="DELETE FROM Usr.User_Role WHERE UserID = @UserID AND RoleID = @RoleID">
        <SelectParameters>
            <asp:ControlParameter Name="UserID" ControlID="GridViewUser" PropertyName="SelectedValue" />
        </SelectParameters>
        <InsertParameters>
            <asp:Parameter Name="UserID" />
            <asp:Parameter Name="RoleID" />
        </InsertParameters>
        <DeleteParameters>
            <asp:Parameter Name="UserID" />
            <asp:Parameter Name="RoleID" />
        </DeleteParameters>
    </asp:SqlDataSource>

</asp:Content>
