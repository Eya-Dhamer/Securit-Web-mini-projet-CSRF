package web;
import dao.DAO;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.*;

public class GestionMessages extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // --- 1. Vérification Anti-CSRF ---
        String sessionToken = (String) request.getSession().getAttribute("csrf_token");
        String formToken = request.getParameter("csrf_token");

        if (sessionToken == null || !sessionToken.equals(formToken)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Jeton CSRF invalide.");
            return;
        }

        String action = request.getParameter("action");
        String user = (String) request.getSession().getAttribute("username");

        // S'assurer qu'un utilisateur est connecté
        if (user == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Le DAO utilise maintenant JDBC pour vérifier le rôle de l'utilisateur
        if (!DAO.isAdmin(user) && !"creer".equals(action)) {
            // Empêche les utilisateurs non-admin d'essayer les actions 'modifier' ou 'supprimer'
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Accès refusé. Rôle insuffisant.");
            return;
        }

        // --- Logique 2. Créer un message ---
        if ("creer".equals(action)) {
            // Note: Nous permettons la création ici, même si l'UI la cache pour les non-admins,
            // car le DAO.ajouterMessage ne vérifie pas le rôle. Le DAO.isAdmin() est vérifié
            // principalement pour les actions sensibles ci-dessous (modifier/supprimer).
            String contenu = request.getParameter("contenu");
            if (contenu != null && !contenu.trim().isEmpty()) {
                DAO.ajouterMessage(contenu, user);
            }
        }

        // --- Logique 3. Modifier un message ---
        if ("modifier".equals(action)) {
            try {
                long messageId = Long.parseLong(request.getParameter("id"));
                String nouveauContenu = request.getParameter("nouveau_contenu");

                // Le DAO vérifie si l'utilisateur est Admin via JDBC
                DAO.modifierMessage(messageId, nouveauContenu, user);

            } catch (NumberFormatException e) {
                System.err.println("[Servlet] Erreur de format ID lors de la modification.");
            }
        }


        // --- Logique 4. Supprimer un message ---
        if ("supprimer".equals(action)) {
            try {
                long messageId = Long.parseLong(request.getParameter("id"));

                // Le DAO vérifie si l'utilisateur est Admin via JDBC
                DAO.supprimerMessage(messageId, user);

            } catch (NumberFormatException e) {
                System.err.println("[Servlet] Erreur de format ID lors de la suppression.");
            }
        }

        // Redirection vers la page avec la liste pour afficher le résultat
        response.sendRedirect("formMessage.jsp");
    }
}