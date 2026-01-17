package dao;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DAO {

    // --- 1. CONFIGURATION DE LA BASE DE DONNÉES ---
    // CORRECTION: Utiliser 'securite_web' ou le nom de DB que vous avez réellement créé.
    private static final String JDBC_URL = "jdbc:mariadb://localhost:3306/csrf";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "";

    // Structure statique pour la gestion des messages (In-Memory pour la SIMULATION)
    private static List<String> messages = new ArrayList<>();

    // SUPPRESSION du bloc static {} pour ne pas avoir de message de démarrage.
    /*
    static {
        messages.add("Message 1: L'ID est basé sur l'index de la liste.");
    }
    */

    // --- Méthode d'utilité pour la connexion ---
    private static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD);
    }

    // ==========================================================
    // MÉTHODES D'AUTHENTIFICATION & GESTION DES RÔLES (JDBC)
    // ==========================================================

    public static boolean checkLogin(String username, String password) {
        String sql = "SELECT username FROM user WHERE username = ? AND password_hash = ?";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username.toLowerCase());
            stmt.setString(2, password);

            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            System.err.println("[DAO Error] Erreur de base de données lors de la vérification de connexion : " + e.getMessage());
            return false;
        }
    }

    public static boolean isAdmin(String username) {
        String sql = "SELECT role FROM user WHERE username = ?";

        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username.toLowerCase());

            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    String role = rs.getString("role");
                    return "ADMIN".equalsIgnoreCase(role);
                }
            }
        } catch (SQLException e) {
            System.err.println("[DAO Error] Erreur de base de données lors de la vérification du rôle : " + e.getMessage());
        }
        return false;
    }

    // ==========================================================
    // MÉTHODES DE GESTION DES MESSAGES (Logique In-Memory)
    // ==========================================================

    // CORRECTION: Stocke uniquement le message sans le préfixe utilisateur/modification.
    public static void ajouterMessage(String message, String user) {
        messages.add(message);
    }

    public static boolean supprimerMessage(long messageId, String user) {
        if (isAdmin(user)) {
            int index = (int) messageId - 1;
            if (index >= 0 && index < messages.size()) {
                messages.remove(index);
                return true;
            }
        }
        return false;
    }

    // CORRECTION: Stocke uniquement le message sans le préfixe utilisateur/modification.
    public static boolean modifierMessage(long messageId, String nouveauContenu, String user) {
        if (isAdmin(user) && messageId > 0 && messageId <= messages.size()) {
            int index = (int) messageId - 1;
            if (nouveauContenu != null && !nouveauContenu.trim().isEmpty()) {
                messages.set(index, nouveauContenu);
                return true;
            }
        }
        return false;
    }

    public static List<String> getMessageList() {
        return messages;
    }
}