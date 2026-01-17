<%@ page import="dao.DAO" %>
<%@ page import="java.util.List" %>
<%
    // Vérification de la session (simplifiée)
    String user = (String) session.getAttribute("username");
    if (user == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // --- NOUVEAU: Gérer l'action de déconnexion ---
    String logoutAction = request.getParameter("logout");
    if ("true".equals(logoutAction)) {
        session.invalidate(); // Détruit la session
        response.sendRedirect("login.jsp");
        return;
    }

    // --- 1. Générer le jeton CSRF s'il n'existe pas
String csrfToken = (String) session.getAttribute("csrf_token");    if (csrfToken == null) {
        csrfToken = java.util.UUID.randomUUID().toString();
        session.setAttribute("csrf_token", csrfToken);
    }

    // Le DAO vérifie le rôle de l'utilisateur via JDBC
    boolean isAdmin = DAO.isAdmin(user);

    // Récupérer la liste des messages
    List<String> messages = DAO.getMessageList();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Gestion des Messages</title>
    <meta charset="UTF-8">

    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h2, h3 { color: #333; }
        /* Style pour le bouton de déconnexion */
        .header-controls { float: right; }
        .logout-button { background-color: #555; color: white; }

        .form-action { margin-bottom: 20px; padding: 15px; border: 1px solid #ccc; border-radius: 5px; clear: both; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        textarea, input[type="text"] { width: 98%; padding: 8px; margin-bottom: 10px; border: 1px solid #ddd; border-radius: 3px; }
        input[type="submit"], button {
            padding: 8px 15px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-right: 5px;
            white-space: nowrap;
        }
        input[type="submit"][value="Envoyer"] { background-color: #4CAF50; color: white; }
        /* CORRECTION de la valeur du bouton en "Éditer" */
        input[type="submit"][value="Éditer"] { background-color: #2196F3; color: white; }
        input[type="submit"][value="Supprimer"] { background-color: #f44336; color: white; }
        table { width: 100%; border-collapse: collapse; }
        th, td { text-align: left; padding: 10px; border: 1px solid #ddd; }
        th { background-color: #f2f2f2; }
    </style>
</head>
<body>

    <div class="header-controls">
        <form action="formMessage.jsp" method="GET" style="display:inline;">
            <input type="hidden" name="logout" value="true">
            <input type="submit" value="Déconnexion" class="logout-button">
        </form>
    </div>

    <h2>Bienvenue, <%= user %></h2>

    <% if (isAdmin) { %>
        <div class="form-action">
            <h3>Créer un nouveau message</h3>

            <form action="GestionMessages" method="POST">
                <input type="hidden" name="csrf_token" value="<%= csrfToken %>">
                <input type="hidden" name="action" value="creer">
                <label for="contenu">Message:</label>
                <textarea id="contenu" name="contenu"></textarea>
                <input type="submit" value="Envoyer">
            </form>
        </div>
    <% } else { %>
        <p>Vous n'avez pas les droits pour créer des messages.</p>
    <% } %>

    <h3>Liste des messages</h3>

    <%-- DÉBUT DU TABLEAU --%>
    <table border="1" cellpadding="5">
        <thead>
            <tr>
                <th>ID</th>
                <th>Contenu du Message</th>
                <% if (isAdmin) { %>
                    <th>Actions</th>
                <% } %>
            </tr>
        </thead>
        <tbody>
        <%
            // Simuler un ID pour chaque message en utilisant l'index
            for (int i = 0; i < messages.size(); i++) {
                String message = messages.get(i);
                long messageId = i + 1; // ID commence à 1
        %>
            <tr>
                <td><%= messageId %></td>
                <td><%= message %></td>
                <% if (isAdmin) { %>
                    <td>
                        <form action="GestionMessages" method="POST" style="display:inline; margin-right: 5px;">
                            <input type="text" name="nouveau_contenu" placeholder="Nouveau message" required style="width: 150px;">
                            <input type="hidden" name="csrf_token" value="<%= csrfToken %>">
                            <input type="hidden" name="action" value="modifier">
                            <input type="hidden" name="id" value="<%= messageId %>">
                            <input type="submit" value="Éditer">
                        </form>

                        <form action="GestionMessages" method="POST" style="display:inline;">
                            <input type="hidden" name="csrf_token" value="<%= csrfToken %>">
                            <input type="hidden" name="action" value="supprimer">
                            <input type="hidden" name="id" value="<%= messageId %>">
                            <input type="submit" value="Supprimer">
                        </form>
                    </td>
                <% } %>
            </tr>
        <%
            }
        %>
        </tbody>
    </table>
    <%-- FIN DU TABLEAU --%>

    </body>
</html>