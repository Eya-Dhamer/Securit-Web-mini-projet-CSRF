<%@ page import="dao.DAO" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <title>Connexion à l'Application</title>
    <meta charset="UTF-8">
</head>
<body>
    <h2>Connexion</h2>

<%
    // Message d'erreur
    String errorMessage = "";

    // Vérification si le formulaire de connexion a été soumis (méthode POST)
    String submittedUser = request.getParameter("username");
    String submittedPass = request.getParameter("password"); // NOUVEAU

    if (submittedUser != null && !submittedUser.isEmpty() && submittedPass != null) {

        // 1. Appel au DAO pour vérifier les identifiants
        if (DAO.checkLogin(submittedUser.trim().toLowerCase(), submittedPass)) {

            // Connexion réussie : définir la session et rediriger
            String cleanedUser = submittedUser.trim().toLowerCase();
            session.setAttribute("username", cleanedUser);

            response.sendRedirect("formMessage.jsp");
            return;

        } else {
            // Échec de la connexion
            errorMessage = "Nom d'utilisateur ou mot de passe incorrect.";
        }
    }

    // Afficher l'erreur si elle existe
    if (!errorMessage.isEmpty()) {
%>
        <p style="color: red;"><%= errorMessage %></p>
<%
    }
%>

    <p>Utilisez : **ali** ou **sami** (mot de passe simulé : **passer**).</p>

    <form action="login.jsp" method="POST">
        <label for="username">Nom d'utilisateur :</label>
        <input type="text" id="username" name="username" required><br><br>

        <label for="password">Mot de passe :</label>
        <input type="password" id="password" name="password" required><br><br>

        <input type="submit" value="Se connecter">
    </form>

</body>
</html>