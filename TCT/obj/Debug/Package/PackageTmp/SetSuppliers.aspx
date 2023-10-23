<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SetSuppliers.aspx.cs" Inherits="TCT.SetSuppliers" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <asp:TextBox ID="NewSupplierNameTextBox" runat="server" Width="200" CssClass="grey"/>
    <asp:RequiredFieldValidator ID="ReqFieldValidatorNewSupplierName" runat="server" ErrorMessage="* Required field"
        ControlToValidate="NewSupplierNameTextBox" ValidationGroup="InsertNewSupplier" CssClass="red" Display="Dynamic" />
    <asp:Button ID="NewSupplierButton" runat="server" CausesValidation="true" ValidationGroup="InsertNewSupplier"
        Text="Create New Supplier" OnClick="NewSupplierButton_Click"/>
        
    <asp:GridView ID="GridViewSupplier" runat="server" AutoGenerateColumns="false" CellPadding="4" ForeColor="#333333" GridLines="None" 
        DataKeyNames="SupplierID" DataSourceID="SqlDataSource_Supplier" EnablePersistedSelection="true" OnRowDataBound="GridViewSupplier_RowDataBound" >
        <AlternatingRowStyle BackColor="White" />
        <Columns>
            <asp:CommandField ButtonType="Button" ShowEditButton="true" />
            <asp:BoundField DataField="Name" HeaderText="Supplier"/>
            <asp:BoundField DataField="Usage" HeaderText="Usage" ReadOnly="true"/>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:LinkButton ID="DeleteSupplierButton" runat="server" CommandName="delete" Text="X"
                        ControlStyle-ForeColor="Red" ControlStyle-Font-Bold="true" ControlStyle-Font-Underline="false"
                        OnClientClick="if (!window.confirm('Delete this Supplier?')) return false;" />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
        <FooterStyle BackColor="#507CD1" Font-Bold="true" ForeColor="White" />
        <HeaderStyle BackColor="#507CD1" Font-Bold="true" ForeColor="White" />
        <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
        <RowStyle BackColor="#EFF3FB" />
        <EditRowStyle BackColor="#D1DDF1" Font-Bold="true" ForeColor="#333333" />
    </asp:GridView>

    <asp:SqlDataSource ID="SqlDataSource_Supplier" runat="server" 
        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
        SelectCommand="SELECT s.SupplierID, s.Name, count(d.DeliveryID) Usage 
            FROM Delivery.Supplier s LEFT JOIN Delivery.DeliveryLine d ON s.SupplierID = d.SupplierID 
            GROUP BY s.SupplierID, s.Name ORDER BY s.Name" 
        InsertCommand="INSERT INTO Delivery.Supplier (Name) VALUES (@Name)" 
        UpdateCommand="UPDATE Delivery.Supplier SET Name = @Name WHERE SupplierID = @SupplierID"
        DeleteCommand="DELETE FROM Delivery.Supplier WHERE SupplierID = @SupplierID">
        <InsertParameters>
            <asp:ControlParameter Name="Name" ControlID="NewSupplierNameTextBox" PropertyName="Text" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="Name" />
            <asp:Parameter Name="SupplierID" />
        </UpdateParameters>
        <DeleteParameters>
            <asp:Parameter Name="SupplierID" />
        </DeleteParameters>
    </asp:SqlDataSource>

</asp:Content>
