<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SetContacts.aspx.cs" Inherits="TCT.SetContacts" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    Contact Name: <asp:TextBox ID="NewContactNameTextBox" runat="server" Width="200" CssClass="grey"/>
    Contact E-mail: <asp:TextBox ID="NewContactEmailTextBox" runat="server" Width="200" CssClass="grey"/>
    <asp:Button ID="NewContactButton" runat="server" Text="Create New Contact" OnClick="NewContactButton_Click"/>
    <br /><br />
        
    <asp:GridView ID="GridViewContact" runat="server" AutoGenerateColumns="False" CellPadding="4" ForeColor="#333333" GridLines="None" 
        DataKeyNames="ContactID" DataSourceID="SqlDataSource_Contact" OnRowEditing="GridViewContact_RowEditing">
        <AlternatingRowStyle BackColor="White" />
        <Columns>
            <asp:CommandField ButtonType="Button" ShowEditButton="true" />
            <asp:BoundField DataField="FullName" HeaderText="Name" />
            <asp:BoundField DataField="Email" HeaderText="Email" />
            <asp:BoundField DataField="Sent" HeaderText="Emails sent" ReadOnly="true" />
        </Columns>
        <HeaderStyle BackColor="#507CD1" Font-Bold="true" ForeColor="White" />
        <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
        <RowStyle BackColor="#EFF3FB" />
        <EditRowStyle BackColor="#D1DDF1" Font-Bold="true" ForeColor="#333333" />
        <SelectedRowStyle BackColor="#D1DDF1" Font-Bold="true" ForeColor="#FF3333" />
    </asp:GridView>

    <asp:SqlDataSource ID="SqlDataSource_Contact" runat="server" 
        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
        SelectCommand="SELECT c.ContactID, c.FullName, c.Email, SUM(CASE WHEN nc.IsSent IS NULL THEN 0 ELSE nc.IsSent END) as Sent
            FROM Usr.Contacts c
            LEFT JOIN Delivery.NotifyContacts nc ON c.ContactID = nc.ContactID
            GROUP BY c.ContactID, c.FullName, c.Email
            ORDER BY c.FullName" 
        InsertCommand="INSERT INTO Usr.Contacts (FullName, Email) VALUES (@FullName, @Email)"
        UpdateCommand="UPDATE Usr.Contacts SET FullName = @FullName, Email = @Email WHERE ContactID = @ContactID">
        <InsertParameters>
            <asp:ControlParameter Name="FullName" ControlID="NewContactNameTextBox" PropertyName="Text" />
            <asp:ControlParameter Name="Email" ControlID="NewContactEmailTextBox" PropertyName="Text" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="FullName" />
            <asp:Parameter Name="Email" />
            <asp:Parameter Name="ContactID" />
        </UpdateParameters>
    </asp:SqlDataSource>

</asp:Content>
