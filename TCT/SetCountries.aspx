<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SetCountries.aspx.cs" Inherits="TCT.SetCountries" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    Name: <asp:TextBox ID="NewCountryNameTextBox" runat="server" Width="200" CssClass="grey"/> &nbsp; 
    Code: <asp:TextBox ID="NewCountryCodeTextBox" runat="server" Width="50" CssClass="grey"/> &nbsp; 
    <asp:Button ID="NewCountryButton" runat="server" Text="Create New Country" OnClick="NewCountryButton_Click"/>
        
    <asp:GridView ID="GridViewCountry" runat="server" AutoGenerateColumns="false" CellPadding="4" ForeColor="#333333" GridLines="None" 
        DataKeyNames="CountryID" DataSourceID="SqlDataSource_Country" EnablePersistedSelection="true">
        <AlternatingRowStyle BackColor="White" />
        <Columns>
            <asp:CommandField ButtonType="Button" ShowEditButton="true" />
            <asp:BoundField DataField="Name" HeaderText="Country"/>
            <asp:BoundField DataField="Code" HeaderText="Code"/>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:LinkButton ID="DeleteCountryButton" runat="server" CommandName="delete" Text="X"
                        ControlStyle-ForeColor="Red" ControlStyle-Font-Bold="true" ControlStyle-Font-Underline="false"
                        OnClientClick="if (!window.confirm('Delete this Country?')) return false;" />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
        <FooterStyle BackColor="#507CD1" Font-Bold="true" ForeColor="White" />
        <HeaderStyle BackColor="#507CD1" Font-Bold="true" ForeColor="White" />
        <PagerStyle BackColor="#2461BF" ForeColor="White" HorizontalAlign="Center" />
        <RowStyle BackColor="#EFF3FB" />
        <EditRowStyle BackColor="#D1DDF1" Font-Bold="true" ForeColor="#333333" />
    </asp:GridView>

    <asp:SqlDataSource ID="SqlDataSource_Country" runat="server" 
        ConnectionString="<%$ ConnectionStrings:CustomsToolConnectionString %>" 
        SelectCommand="SELECT CountryID, Name, Code FROM Delivery.Country ORDER BY Name" 
        InsertCommand="INSERT INTO Delivery.Country (Name, Code) VALUES (@Name, @Code)" 
        UpdateCommand="UPDATE Delivery.Country SET Name = @Name, Code = @Code WHERE CountryID = @CountryID"
        DeleteCommand="DELETE FROM Delivery.Country WHERE CountryID = @CountryID">
        <InsertParameters>
            <asp:ControlParameter Name="Name" ControlID="NewCountryNameTextBox" PropertyName="Text" />
            <asp:ControlParameter Name="Code" ControlID="NewCountryCodeTextBox" PropertyName="Text" />
        </InsertParameters>
        <UpdateParameters>
            <asp:Parameter Name="Name" />
            <asp:Parameter Name="Code" />
            <asp:Parameter Name="CountryID" />
        </UpdateParameters>
        <DeleteParameters>
            <asp:Parameter Name="CountryID" />
        </DeleteParameters>
    </asp:SqlDataSource>

</asp:Content>
