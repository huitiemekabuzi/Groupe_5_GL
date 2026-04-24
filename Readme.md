# 📚 DOCUMENTATION POSTMAN + APPLICATION FLUTTER COMPLÈTE

## PARTIE 1 : DOCUMENTATION POSTMAN

```markdown
# ISMGL API - Documentation Complète des Tests Postman

**Version:** 1.0.0  
**Base URL:** `http://localhost/ismgl-api/api/v1`  
**Format:** JSON  
**Authentification:** Bearer Token (JWT)

---

# Configuration Globale Postman

### Variables d'environnement
| Variable | Valeur initiale | Description |
|----------|----------------|-------------|
| `base_url` | `http://localhost/ismgl-api/api/v1` | URL de base |
| `token` | `` | JWT Token (auto-rempli après login) |
| `refresh_token` | `` | Refresh Token |
| `etudiant_id` | `` | ID étudiant courant |
| `inscription_id` | `` | ID inscription courante |
| `paiement_id` | `` | ID paiement courant |

### Script Pre-request Global
```javascript
pm.request.headers.add({
    key: 'Content-Type',
    value: 'application/json'
});
pm.request.headers.add({
    key: 'Accept',
    value: 'application/json'
});
```

### Script Test Global (Auto-save token)
```javascript
if (pm.response.code === 200 || pm.response.code === 201) {
    const response = pm.response.json();
    if (response.data && response.data.token) {
        pm.environment.set('token', response.data.token);
        pm.environment.set('refresh_token', response.data.refresh_token);
    }
}
```

---

# 1. MODULE AUTHENTIFICATION

### 1.1 Connexion
**`POST`** `/auth/login`

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
    "email": "admin@ismgl.cd",
    "mot_de_passe": "Admin@123"
}
```

** Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "message": "Connexion réussie",
    "timestamp": "2024-01-15 10:30:00",
    "data": {
        "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
        "refresh_token": "a1b2c3d4e5f6...",
        "expires_in": 86400,
        "user": {
            "id": 1,
            "matricule": "ADMIN001",
            "nom": "Super",
            "prenom": "Admin",
            "email": "admin@ismgl.cd",
            "telephone": "+243812345678",
            "photo_profil": null,
            "role": {
                "id": 1,
                "nom": "Administrateur"
            }
        }
    }
}
```

**❌ Réponse Erreur (401):**
```json
{
    "success": false,
    "status_code": 401,
    "message": "Email ou mot de passe incorrect",
    "timestamp": "2024-01-15 10:30:00",
    "data": null
}
```

**❌ Compte Bloqué (423):**
```json
{
    "success": false,
    "status_code": 423,
    "message": "Compte bloqué. Réessayez dans 25 minutes.",
    "timestamp": "2024-01-15 10:30:00",
    "data": null
}
```

---

### 1.2 Déconnexion
**`POST`** `/auth/logout`

**Headers:**
```
Authorization: Bearer {{token}}
Content-Type: application/json
```

**Body:** *(vide)*

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "message": "Déconnexion réussie",
    "timestamp": "2024-01-15 10:45:00",
    "data": null
}
```

---

### 1.3 Rafraîchir le Token
**`POST`** `/auth/refresh`

**Headers:**
```
Content-Type: application/json
```

**Body (JSON):**
```json
{
    "refresh_token": "{{refresh_token}}"
}
```

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "message": "Token rafraîchi avec succès",
    "data": {
        "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
        "refresh_token": "new_refresh_token_here",
        "expires_in": 86400
    }
}
```

**❌ Réponse Erreur (401):**
```json
{
    "success": false,
    "status_code": 401,
    "message": "Refresh token invalide",
    "data": null
}
```

---

### 1.4 Profil Connecté
**`GET`** `/auth/me`

**Headers:**
```
Authorization: Bearer {{token}}
```

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "message": null,
    "data": {
        "id_user": 1,
        "matricule": "ADMIN001",
        "nom": "Super",
        "prenom": "Admin",
        "email": "admin@ismgl.cd",
        "telephone": "+243812345678",
        "id_role": 1,
        "nom_role": "Administrateur",
        "est_actif": true,
        "derniere_connexion": "2024-01-15 10:30:00",
        "permissions": [
            {
                "id_permission": 1,
                "code_permission": "user.create",
                "module": "Utilisateurs",
                "nom_permission": "Créer utilisateur"
            }
        ]
    }
}
```

---

### 1.5 Changer le Mot de Passe
**`POST`** `/auth/change-password`

**Headers:**
```
Authorization: Bearer {{token}}
Content-Type: application/json
```

**Body (JSON):**
```json
{
    "ancien_mot_de_passe": "Admin@123",
    "nouveau_mot_de_passe": "NewPass@456",
    "confirmation_mot_de_passe": "NewPass@456"
}
```

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "message": "Mot de passe modifié avec succès",
    "data": null
}
```

**❌ Réponse Erreur (422):**
```json
{
    "success": false,
    "status_code": 422,
    "message": "Erreur de validation des données.",
    "data": {
        "errors": {
            "nouveau_mot_de_passe": "Le mot de passe doit contenir au moins 8 caractères, une majuscule, une minuscule, un chiffre, un caractère spécial"
        }
    }
}
```

---

### 1.6 Mot de Passe Oublié
**`POST`** `/auth/forgot-password`

**Body (JSON):**
```json
{
    "email": "etudiant@ismgl.cd"
}
```

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "message": "Si l'email existe, un lien de réinitialisation a été envoyé",
    "data": null
}
```

---

### 1.7 Réinitialiser le Mot de Passe
**`POST`** `/auth/reset-password`

**Body (JSON):**
```json
{
    "token": "abc123def456...",
    "nouveau_mot_de_passe": "NewPass@789",
    "confirmation_mot_de_passe": "NewPass@789"
}
```

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "message": "Mot de passe réinitialisé avec succès",
    "data": null
}
```

**❌ Token Expiré (400):**
```json
{
    "success": false,
    "status_code": 400,
    "message": "Token invalide ou expiré",
    "data": null
}
```

---

## 📊 2. MODULE DASHBOARD

### 2.1 Dashboard Principal
**`GET`** `/dashboard`

**Headers:**
```
Authorization: Bearer {{token}}
```

**✅ Réponse Admin (200):**
```json
{
    "success": true,
    "status_code": 200,
    "data": {
        "role": "Administrateur",
        "annee_courante": {
            "id_annee_academique": 1,
            "code_annee": "2023-2024",
            "est_courante": true
        },
        "statistiques": {
            "total_etudiants_actifs": 450,
            "total_inscriptions": 420,
            "inscriptions_payees": 380,
            "montant_total_attendu": 210000000,
            "montant_total_percu": 190000000,
            "montant_total_impaye": 20000000,
            "paiements_aujourdhui": 15,
            "montant_aujourdhui": 7500000
        },
        "paiements_recents": [...],
        "inscriptions_recentes": [...],
        "etudiants_impayes_count": 40,
        "utilisateurs_actifs": 25
    }
}
```

**✅ Réponse Caissier (200):**
```json
{
    "success": true,
    "status_code": 200,
    "data": {
        "role": "Caissier",
        "paiements_aujourd_hui": [...],
        "montant_aujourd_hui": 3500000,
        "nombre_paiements_jour": 8,
        "rapport_modes_paiement": [
            {"nom_mode": "Espèces", "nombre": 5, "total": 2500000},
            {"nom_mode": "Mobile Money", "nombre": 3, "total": 1000000}
        ]
    }
}
```

---

## 👥 3. MODULE UTILISATEURS

### 3.1 Liste des Utilisateurs
**`GET`** `/users`

**Headers:**
```
Authorization: Bearer {{token}}
```

**Paramètres Query:**
```
page=1
page_size=20
role=1
actif=1
search=admin
```

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "data": {
        "items": [
            {
                "id_user": 1,
                "matricule": "ADMIN001",
                "nom": "Super",
                "prenom": "Admin",
                "email": "admin@ismgl.cd",
                "telephone": "+243812345678",
                "nom_role": "Administrateur",
                "est_actif": true,
                "derniere_connexion": "2024-01-15 10:30:00",
                "compte_bloque": false,
                "date_creation": "2024-01-01 00:00:00"
            }
        ],
        "pagination": {
            "current_page": 1,
            "page_size": 20,
            "total_items": 25,
            "total_pages": 2,
            "has_next": true,
            "has_previous": false
        }
    }
}
```

---

### 3.2 Détail Utilisateur
**`GET`** `/users/{id}`

**Headers:**
```
Authorization: Bearer {{token}}
```

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "data": {
        "id_user": 2,
        "matricule": "CAI001",
        "nom": "Dupont",
        "prenom": "Jean",
        "email": "caissier@ismgl.cd",
        "telephone": "+243823456789",
        "id_role": 2,
        "nom_role": "Caissier",
        "est_actif": true,
        "compte_bloque": false,
        "date_creation": "2024-01-05 09:00:00"
    }
}
```

**❌ Non Trouvé (404):**
```json
{
    "success": false,
    "status_code": 404,
    "message": "Utilisateur non trouvé",
    "data": null
}
```

---

### 3.3 Créer Utilisateur
**`POST`** `/users`

**Headers:**
```
Authorization: Bearer {{token}}
Content-Type: application/json
```

**Body (JSON):**
```json
{
    "matricule": "CAI002",
    "nom": "Martin",
    "prenom": "Pierre",
    "email": "pierre.martin@ismgl.cd",
    "telephone": "+243834567890",
    "mot_de_passe": "Pass@1234",
    "id_role": 2,
    "est_actif": true
}
```

**✅ Réponse Succès (201):**
```json
{
    "success": true,
    "status_code": 201,
    "message": "Utilisateur créé avec succès",
    "data": {
        "id_user": 10,
        "matricule": "CAI002",
        "nom": "Martin",
        "prenom": "Pierre",
        "email": "pierre.martin@ismgl.cd",
        "nom_role": "Caissier",
        "est_actif": true
    }
}
```

**❌ Email Dupliqué (422):**
```json
{
    "success": false,
    "status_code": 422,
    "message": "Erreur de validation des données.",
    "data": {
        "errors": {
            "email": "Cette valeur existe déjà"
        }
    }
}
```

---

### 3.4 Modifier Utilisateur
**`PUT`** `/users/{id}`

**Headers:**
```
Authorization: Bearer {{token}}
Content-Type: application/json
```

**Body (JSON):**
```json
{
    "nom": "Martin",
    "prenom": "Pierre-Paul",
    "telephone": "+243845678901",
    "id_role": 2
}
```

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "message": "Mis à jour avec succès",
    "data": {
        "id_user": 10,
        "nom": "Martin",
        "prenom": "Pierre-Paul",
        "email": "pierre.martin@ismgl.cd",
        "nom_role": "Caissier"
    }
}
```

---

### 3.5 Supprimer Utilisateur
**`DELETE`** `/users/{id}`

**Headers:**
```
Authorization: Bearer {{token}}
```

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "message": "Supprimé avec succès",
    "data": null
}
```

---

### 3.6 Activer/Désactiver Utilisateur
**`PATCH`** `/users/{id}/toggle`

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "message": "Statut modifié avec succès",
    "data": {"est_actif": false}
}
```

### 3.7 Déverrouiller Compte
**`PATCH`** `/users/{id}/unlock`

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "message": "Compte déverrouillé avec succès",
    "data": null
}
```

---

## 🎓 4. MODULE ÉTUDIANTS

### 4.1 Liste des Étudiants
**`GET`** `/etudiants`

**Paramètres Query:**
```
page=1
page_size=20
statut=Actif
sexe=M
search=Jean
```

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "data": {
        "items": [
            {
                "id_etudiant": 1,
                "numero_etudiant": "ETU2024000001",
                "matricule": "ETU2024000001",
                "nom": "Kabila",
                "prenom": "Jean",
                "email": "jean.kabila@ismgl.cd",
                "telephone": "+243856789012",
                "date_naissance": "2000-05-15",
                "sexe": "M",
                "statut": "Actif",
                "date_premiere_inscription": "2024-09-01",
                "est_actif": true
            }
        ],
        "pagination": {
            "current_page": 1,
            "page_size": 20,
            "total_items": 450,
            "total_pages": 23,
            "has_next": true,
            "has_previous": false
        }
    }
}
```

---

### 4.2 Détail Étudiant
**`GET`** `/etudiants/{id}`

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "data": {
        "id_etudiant": 1,
        "numero_etudiant": "ETU2024000001",
        "nom": "Kabila",
        "prenom": "Jean",
        "email": "jean.kabila@ismgl.cd",
        "telephone": "+243856789012",
        "date_naissance": "2000-05-15",
        "lieu_naissance": "Lubumbashi",
        "sexe": "M",
        "nationalite": "Congolaise",
        "adresse": "Avenue Kasai, N°45",
        "ville": "Lubumbashi",
        "province": "Haut-Katanga",
        "nom_pere": "Kabila Senior",
        "nom_mere": "Marie Kabila",
        "telephone_urgence": "+243867890123",
        "groupe_sanguin": "O+",
        "statut": "Actif",
        "photo_identite": null,
        "est_actif": true
    }
}
```

---

### 4.3 Créer Étudiant
**`POST`** `/etudiants`

**Headers:**
```
Authorization: Bearer {{token}}
Content-Type: multipart/form-data
```

**Body (form-data):**
```
nom: Mukendi
prenom: Paul
email: paul.mukendi@ismgl.cd
telephone: +243878901234
mot_de_passe: Student@123
date_naissance: 2001-03-20
lieu_naissance: Kinshasa
sexe: M
nationalite: Congolaise
adresse: Quartier Makutano, N°12
ville: Lubumbashi
province: Haut-Katanga
nom_pere: Joseph Mukendi
nom_mere: Marie Mukendi
telephone_urgence: +243889012345
groupe_sanguin: A+
photo_profil: [fichier image]
photo_identite: [fichier image]
```

**✅ Réponse Succès (201):**
```json
{
    "success": true,
    "status_code": 201,
    "message": "Étudiant créé avec succès",
    "data": {
        "id_etudiant": 5,
        "numero_etudiant": "ETU2024000005",
        "nom": "Mukendi",
        "prenom": "Paul",
        "email": "paul.mukendi@ismgl.cd",
        "statut": "Actif"
    }
}
```

---

### 4.4 Mon Profil Étudiant
**`GET`** `/etudiants/me`

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "data": {
        "id_etudiant": 3,
        "numero_etudiant": "ETU2024000003",
        "nom": "Tshisekedi",
        "prenom": "Marie",
        "email": "marie.tshisekedi@ismgl.cd",
        "statut": "Actif",
        "date_premiere_inscription": "2024-09-01"
    }
}
```

---

### 4.5 Modifier Statut Étudiant
**`PATCH`** `/etudiants/{id}/statut`

**Body (JSON):**
```json
{
    "statut": "Suspendu"
}
```

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "message": "Statut mis à jour avec succès",
    "data": {"statut": "Suspendu"}
}
```

---

## 📝 5. MODULE INSCRIPTIONS

### 5.1 Liste des Inscriptions
**`GET`** `/inscriptions`

**Paramètres Query:**
```
page=1
page_size=20
annee_academique=1
filiere=2
niveau=1
statut=Validée
type=Nouvelle
search=Kabila
```

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "data": {
        "items": [
            {
                "id_inscription": 1,
                "numero_inscription": "INS-2024-0001",
                "date_inscription": "2024-09-01 08:30:00",
                "numero_etudiant": "ETU2024000001",
                "nom": "Kabila",
                "prenom": "Jean",
                "nom_filiere": "Informatique de Gestion",
                "nom_niveau": "Licence 1",
                "code_annee": "2023-2024",
                "type_inscription": "Nouvelle",
                "statut_inscription": "Validée",
                "montant_total": 615000.00,
                "montant_paye": 615000.00,
                "montant_restant": 0.00,
                "est_complete": true,
                "pourcentage_paye": "100.00%"
            }
        ],
        "pagination": {
            "current_page": 1,
            "page_size": 20,
            "total_items": 420,
            "total_pages": 21,
            "has_next": true,
            "has_previous": false
        }
    }
}
```

---

### 5.2 Créer Inscription
**`POST`** `/inscriptions`

**Body (JSON):**
```json
{
    "id_etudiant": 5,
    "id_filiere": 2,
    "id_niveau": 1,
    "id_annee_academique": 1,
    "type_inscription": "Nouvelle"
}
```

**✅ Réponse Succès (201):**
```json
{
    "success": true,
    "status_code": 201,
    "message": "Inscription enregistrée avec succès",
    "data": {
        "id_inscription": 25,
        "numero_inscription": "INS-2024-0025",
        "date_inscription": "2024-01-15 11:00:00",
        "nom_filiere": "Informatique de Gestion",
        "nom_niveau": "Licence 1",
        "type_inscription": "Nouvelle",
        "statut_inscription": "En attente",
        "montant_total": 615000.00,
        "montant_paye": 0.00,
        "montant_restant": 615000.00,
        "est_complete": false
    }
}
```

**❌ Inscription Existante (400):**
```json
{
    "success": false,
    "status_code": 400,
    "message": "L'étudiant est déjà inscrit pour cette année académique",
    "data": null
}
```

---

### 5.3 Valider Inscription
**`PATCH`** `/inscriptions/{id}/valider`

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "message": "Inscription validée avec succès",
    "data": null
}
```

---

### 5.4 Rejeter Inscription
**`PATCH`** `/inscriptions/{id}/rejeter`

**Body (JSON):**
```json
{
    "motif": "Documents incomplets. Veuillez fournir votre diplôme original."
}
```

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "message": "Inscription rejetée",
    "data": null
}
```

---

### 5.5 Mes Inscriptions
**`GET`** `/inscriptions/me`

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "data": [
        {
            "id_inscription": 1,
            "numero_inscription": "INS-2024-0001",
            "nom_filiere": "Informatique de Gestion",
            "nom_niveau": "Licence 1",
            "code_annee": "2023-2024",
            "statut_inscription": "Validée",
            "montant_total": 615000.00,
            "montant_paye": 615000.00,
            "est_complete": true
        }
    ]
}
```

---

## 💰 6. MODULE PAIEMENTS

### 6.1 Liste des Paiements
**`GET`** `/paiements`

**Paramètres Query:**
```
page=1
page_size=20
date_debut=2024-01-01
date_fin=2024-01-31
caissier=2
mode_paiement=1
statut=Validé
search=PAY-2024
```

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "data": {
        "items": [
            {
                "id_paiement": 1,
                "numero_paiement": "PAY-2024-01-0001",
                "date_paiement": "2024-01-15 09:30:00",
                "numero_etudiant": "ETU2024000001",
                "nom_complet_etudiant": "Kabila Jean",
                "numero_inscription": "INS-2024-0001",
                "nom_frais": "Frais de scolarité",
                "montant": 500000.00,
                "mode_paiement": "Espèces",
                "reference_transaction": null,
                "recu_par_nom": "Dupont Jean",
                "statut_paiement": "Validé",
                "numero_recu": "REC-2024-00001"
            }
        ],
        "pagination": {
            "current_page": 1,
            "page_size": 20,
            "total_items": 850,
            "total_pages": 43,
            "has_next": true,
            "has_previous": false
        }
    }
}
```

---

### 6.2 Enregistrer Paiement
**`POST`** `/paiements`

**Body (JSON):**
```json
{
    "id_inscription": 25,
    "id_etudiant": 5,
    "id_type_frais": 1,
    "id_mode_paiement": 1,
    "montant": 500000,
    "reference_transaction": null
}
```

**✅ Réponse Succès (201):**
```json
{
    "success": true,
    "status_code": 201,
    "message": "Paiement enregistré avec succès",
    "data": {
        "id_paiement": 50,
        "numero_paiement": "PAY-2024-01-0050",
        "date_paiement": "2024-01-15 11:30:00",
        "nom_complet_etudiant": "Mukendi Paul",
        "nom_frais": "Frais de scolarité",
        "montant": 500000.00,
        "mode_paiement": "Espèces",
        "statut_paiement": "Validé",
        "numero_recu": "REC-2024-00050"
    }
}
```

**❌ Montant Invalide (422):**
```json
{
    "success": false,
    "status_code": 422,
    "message": "Erreur de validation des données.",
    "data": {
        "errors": {
            "montant": "Le champ montant doit être supérieur ou égal à 0"
        }
    }
}
```

---

### 6.3 Annuler Paiement
**`PATCH`** `/paiements/{id}/annuler`

**Body (JSON):**
```json
{
    "motif": "Erreur de saisie - montant incorrect"
}
```

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "message": "Paiement annulé avec succès",
    "data": null
}
```

---

### 6.4 Rapport Journalier Caisse
**`GET`** `/paiements/journalier`

**Paramètres Query:**
```
date=2024-01-15
caissier=2
```

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "data": {
        "date": "2024-01-15",
        "montant_total": 7500000.00,
        "caissier": "2"
    }
}
```

---

## 🧾 7. MODULE REÇUS

### 7.1 Détail Reçu
**`GET`** `/recus/{id}`

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "data": {
        "id_recu": 1,
        "numero_recu": "REC-2024-00001",
        "date_emission": "2024-01-15 09:30:00",
        "numero_paiement": "PAY-2024-01-0001",
        "date_paiement": "2024-01-15 09:30:00",
        "montant_total": 500000.00,
        "numero_etudiant": "ETU2024000001",
        "nom_complet_etudiant": "Kabila Jean",
        "email": "jean.kabila@ismgl.cd",
        "nom_frais": "Frais de scolarité",
        "mode_paiement": "Espèces",
        "reference_transaction": null,
        "numero_inscription": "INS-2024-0001",
        "nom_filiere": "Informatique de Gestion",
        "nom_niveau": "Licence 1",
        "code_annee": "2023-2024",
        "emis_par_nom": "Dupont Jean",
        "est_imprime": true,
        "nombre_impressions": 2
    }
}
```

---

### 7.2 Générer Reçu PDF
**`GET`** `/recus/{id}/generate`

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "message": "Reçu généré avec succès",
    "data": {
        "pdf_url": "http://localhost/ismgl-api/uploads/recus/recu_REC-2024-00001_1705312200.html",
        "numero_recu": "REC-2024-00001"
    }
}
```

---

### 7.3 Télécharger Reçu
**`GET`** `/recus/{id}/download`

**📥 Réponse:** Fichier PDF en téléchargement direct  
**Headers de réponse:**
```
Content-Type: application/pdf
Content-Disposition: attachment; filename="recu_REC-2024-00001.pdf"
```

---

## 🏫 8. MODULE FILIÈRES

### 8.1 Liste des Filières
**`GET`** `/filieres`

**✅ Réponse Succès (200):**
```json
{
    "success": true,
    "status_code": 200,
    "data": [
        {
            "id_filiere": 1,
            "code_filiere": "IG",
            "nom_filiere": "Informatique de Gestion",
            "id_departement": 1,
            "nom_departement": "Informatique",
            "nom_faculte": "Sciences et Technologies",
            "diplome_delivre": "Licence",
            "duree_etudes": 3,
            "est_actif": true
        }
    ]
}
```

---

### 8.2 Créer Filière
**`POST`** `/filieres`

**Body (JSON):**
```json
{
    "code_filiere": "GC",
    "nom_filiere": "Génie Civil",
    "id_departement": 2,
    "diplome_delivre": "Licence",
    "duree_etudes": 3,
    "description": "Formation en génie civil et construction"
}
```

**✅ Réponse Succès (201):**
```json
{
    "success": true,
    "status_code": 201,
    "message": "Filière créée avec succès",
    "data": {
        "id_filiere": 5,
        "code_filiere": "GC",
        "nom_filiere": "Génie Civil",
        "nom_departement": "Génie et Architecture",
        "est_actif": true
    }
}
```

---

## ⚙️ 9. MODULE CONFIGURATION

### 9.1 Années Académiques

#### Liste
**`GET`** `/config/annees`

**✅ Réponse (200):**
```json
{
    "success": true,
    "data": [
        {
            "id_annee_academique": 1,
            "code_annee": "2023-2024",
            "annee_debut": 2023,
            "annee_fin": 2024,
            "date_debut": "2023-09-01",
            "date_fin": "2024-08-31",
            "est_courante": true,
            "est_cloturee": false
        }
    ]
}
```

#### Créer
**`POST`** `/config/annees`

**Body (JSON):**
```json
{
    "code_annee": "2024-2025",
    "annee_debut": 2024,
    "annee_fin": 2025,
    "date_debut": "2024-09-01",
    "date_fin": "2025-08-31",
    "est_courante": false
}
```

#### Définir Courante
**`PATCH`** `/config/annees/{id}/courante`

**✅ Réponse (200):**
```json
{
    "success": true,
    "message": "Année académique définie comme courante",
    "data": null
}
```

#### Clôturer
**`PATCH`** `/config/annees/{id}/cloturer`

**✅ Réponse (200):**
```json
{
    "success": true,
    "message": "Année académique clôturée avec succès",
    "data": null
}
```

---

### 9.2 Types de Frais

#### Liste
**`GET`** `/config/types-frais`

**✅ Réponse (200):**
```json
{
    "success": true,
    "data": [
        {
            "id_type_frais": 1,
            "code_frais": "SCOL",
            "nom_frais": "Frais de scolarité",
            "montant_base": 500000.00,
            "est_obligatoire": true,
            "est_actif": true
        },
        {
            "id_type_frais": 2,
            "code_frais": "INSC",
            "nom_frais": "Frais d'inscription",
            "montant_base": 50000.00,
            "est_obligatoire": true,
            "est_actif": true
        }
    ]
}
```

#### Créer
**`POST`** `/config/types-frais`

**Body (JSON):**
```json
{
    "code_frais": "EXAM",
    "nom_frais": "Frais d'examens",
    "description": "Frais pour les examens de fin d'année",
    "montant_base": 35000,
    "est_obligatoire": true
}
```

---

### 9.3 Frais de Scolarité

#### Par Filière/Niveau
**`GET`** `/config/frais-scolarite?filiere=1&niveau=1&annee=1`

**✅ Réponse (200):**
```json
{
    "success": true,
    "data": {
        "frais": [
            {
                "id_frais": 1,
                "nom_frais": "Frais de scolarité",
                "montant": 500000.00,
                "est_obligatoire": true
            },
            {
                "id_frais": 2,
                "nom_frais": "Frais d'inscription",
                "montant": 50000.00,
                "est_obligatoire": true
            },
            {
                "id_frais": 3,
                "nom_frais": "Frais de bibliothèque",
                "montant": 25000.00,
                "est_obligatoire": true
            }
        ],
        "montant_total": 615000.00
    }
}
```

---

### 9.4 Niveaux
**`GET`** `/config/niveaux`

**✅ Réponse (200):**
```json
{
    "success": true,
    "data": [
        {"id_niveau": 1, "code_niveau": "L1", "nom_niveau": "Licence 1", "ordre": 1},
        {"id_niveau": 2, "code_niveau": "L2", "nom_niveau": "Licence 2", "ordre": 2},
        {"id_niveau": 3, "code_niveau": "L3", "nom_niveau": "Licence 3", "ordre": 3},
        {"id_niveau": 4, "code_niveau": "M1", "nom_niveau": "Master 1", "ordre": 4},
        {"id_niveau": 5, "code_niveau": "M2", "nom_niveau": "Master 2", "ordre": 5}
    ]
}
```

---

### 9.5 Facultés & Départements

**`GET`** `/config/facultes`
**`GET`** `/config/departements?faculte=1`
**`GET`** `/config/modes-paiement`

**✅ Modes de Paiement (200):**
```json
{
    "success": true,
    "data": [
        {"id_mode_paiement": 1, "code_mode": "ESPECES", "nom_mode": "Espèces"},
        {"id_mode_paiement": 2, "code_mode": "MOBILE", "nom_mode": "Mobile Money"},
        {"id_mode_paiement": 3, "code_mode": "VIREMENT", "nom_mode": "Virement bancaire"}
    ]
}
```

---

### 9.6 Rôles & Permissions

**`GET`** `/config/roles`
**`GET`** `/config/roles/{id}/permissions`
**`POST`** `/config/roles/{id}/permissions`

**Body Attribution Permissions:**
```json
{
    "permissions": [1, 2, 5, 8, 12, 15]
}
```

**`GET`** `/config/permissions`

**✅ Permissions par Module (200):**
```json
{
    "success": true,
    "data": {
        "Utilisateurs": [
            {"id_permission": 1, "code_permission": "user.create", "nom_permission": "Créer utilisateur"},
            {"id_permission": 2, "code_permission": "user.update", "nom_permission": "Modifier utilisateur"}
        ],
        "Etudiants": [
            {"id_permission": 5, "code_permission": "etudiant.create", "nom_permission": "Créer étudiant"}
        ],
        "Paiements": [
            {"id_permission": 13, "code_permission": "paiement.create", "nom_permission": "Créer paiement"}
        ]
    }
}
```

---

## 📊 10. MODULE RAPPORTS

### 10.1 Statistiques Globales
**`GET`** `/rapports/statistiques?annee=1`

**✅ Réponse (200):**
```json
{
    "success": true,
    "data": {
        "total_etudiants_actifs": 450,
        "total_inscriptions": 420,
        "inscriptions_payees": 380,
        "montant_total_attendu": 258300000.00,
        "montant_total_percu": 233650000.00,
        "montant_total_impaye": 24650000.00,
        "paiements_aujourdhui": 12,
        "montant_aujourdhui": 6150000.00
    }
}
```

---

### 10.2 Rapport Paiements par Période
**`GET`** `/rapports/paiements?date_debut=2024-01-01&date_fin=2024-01-31&caissier=2`

**✅ Réponse (200):**
```json
{
    "success": true,
    "data": {
        "periode": {
            "date_debut": "2024-01-01",
            "date_fin": "2024-01-31"
        },
        "total_montant": 45750000.00,
        "nombre": 85,
        "paiements": [
            {
                "numero_paiement": "PAY-2024-01-0001",
                "date_paiement": "2024-01-02 09:15:00",
                "etudiant": "Kabila Jean",
                "nom_frais": "Frais de scolarité",
                "montant": 500000.00,
                "mode_paiement": "Espèces",
                "reference_transaction": null,
                "statut_paiement": "Validé"
            }
        ]
    }
}
```

---

### 10.3 Rapport Journalier Caisse
**`GET`** `/rapports/journalier?date=2024-01-15`

**✅ Réponse (200):**
```json
{
    "success": true,
    "data": {
        "date": "2024-01-15",
        "montant_total": 12350000.00,
        "details": [
            {
                "date_operation": "2024-01-15",
                "nombre_transactions": 8,
                "montant_total": 8350000.00,
                "nom_mode": "Espèces",
                "caissier": "Dupont Jean"
            },
            {
                "date_operation": "2024-01-15",
                "nombre_transactions": 4,
                "montant_total": 4000000.00,
                "nom_mode": "Mobile Money",
                "caissier": "Dupont Jean"
            }
        ]
    }
}
```

---

### 10.4 Étudiants Impayés
**`GET`** `/rapports/impayes?annee=1`

**✅ Réponse (200):**
```json
{
    "success": true,
    "data": {
        "nombre_etudiants": 40,
        "montant_total": 24650000.00,
        "etudiants": [
            {
                "numero_etudiant": "ETU2024000015",
                "nom_complet": "Nkosi Albert",
                "email": "albert.nkosi@ismgl.cd",
                "numero_inscription": "INS-2024-0015",
                "nom_filiere": "Droit",
                "nom_niveau": "Licence 2",
                "montant_total": 615000.00,
                "montant_paye": 0.00,
                "montant_restant": 615000.00,
                "jours_depuis_inscription": 45
            }
        ]
    }
}
```

---

### 10.5 Statistiques par Filière
**`GET`** `/rapports/filieres?annee=1`

**✅ Réponse (200):**
```json
{
    "success": true,
    "data": [
        {
            "id_filiere": 1,
            "nom_filiere": "Informatique de Gestion",
            "code_annee": "2023-2024",
            "nombre_inscriptions": 120,
            "inscriptions_completes": 108,
            "montant_total_attendu": 73800000.00,
            "montant_total_percu": 66420000.00,
            "montant_total_restant": 7380000.00
        }
    ]
}
```

---

### 10.6 Récapitulatif Financier
**`GET`** `/rapports/financier?annee=1`

**✅ Réponse (200):**
```json
{
    "success": true,
    "data": {
        "montant_attendu": 258300000.00,
        "montant_percu": 233650000.00,
        "montant_impaye": 24650000.00,
        "nombre_inscriptions": 420,
        "inscriptions_completes": 380,
        "taux_recouvrement": 90.46
    }
}
```

---

### 10.7 Situation Étudiant
**`GET`** `/rapports/etudiant/{id}?annee=1`

**✅ Réponse (200):**
```json
{
    "success": true,
    "data": {
        "inscription": {
            "numero_inscription": "INS-2024-0001",
            "nom_filiere": "Informatique de Gestion",
            "nom_niveau": "Licence 1",
            "montant_total": 615000.00,
            "montant_paye": 615000.00,
            "montant_restant": 0.00,
            "est_complete": true,
            "statut_inscription": "Validée"
        },
        "paiements": [
            {
                "numero_paiement": "PAY-2024-01-0001",
                "date_paiement": "2024-01-15 09:30:00",
                "nom_frais": "Frais de scolarité",
                "montant": 500000.00,
                "nom_mode": "Espèces",
                "numero_recu": "REC-2024-00001"
            }
        ]
    }
}
```

---

### 10.8 Export PDF
**`GET`** `/rapports/export/pdf?type=paiements&date_debut=2024-01-01&date_fin=2024-01-31`

**Types disponibles:** `general`, `paiements`, `impayes`, `filieres`

**✅ Réponse (200):**
```json
{
    "success": true,
    "message": "Rapport généré avec succès",
    "data": {
        "pdf_url": "http://localhost/ismgl-api/uploads/documents/rapport_paiements_2024-01-15_10-30-00.html",
        "type": "paiements"
    }
}
```

---

### 10.9 Export CSV
**`GET`** `/rapports/export/csv?type=paiements&date_debut=2024-01-01&date_fin=2024-01-31`

**📥 Réponse:** Fichier CSV en téléchargement direct

---

### 10.10 Logs d'Activité
**`GET`** `/rapports/logs?page=1&module=Paiements&date_debut=2024-01-01`

**✅ Réponse (200):**
```json
{
    "success": true,
    "data": {
        "items": [
            {
                "id_log": 1,
                "utilisateur": "Dupont Jean",
                "action": "CREATE_PAIEMENT",
                "module": "Paiements",
                "description": "Enregistrement du paiement PAY-2024-01-0001",
                "ip_address": "192.168.1.100",
                "date_action": "2024-01-15 09:30:00"
            }
        ],
        "pagination": {...}
    }
}
```

---

## 🔔 11. MODULE NOTIFICATIONS

### 11.1 Liste des Notifications
**`GET`** `/notifications?limit=20`

**✅ Réponse (200):**
```json
{
    "success": true,
    "data": {
        "notifications": [
            {
                "id_notification": 1,
                "titre": "Paiement confirmé",
                "message": "Votre paiement de 500 000 FC a été enregistré. N° PAY-2024-01-0001",
                "type_notification": "Succès",
                "est_lu": false,
                "lien": "/paiements/1",
                "date_creation": "2024-01-15 09:30:00"
            }
        ],
        "total_non_lues": 3
    }
}
```

---

### 11.2 Nombre Non Lues
**`GET`** `/notifications/count`

**✅ Réponse (200):**
```json
{
    "success": true,
    "data": {"count": 3}
}
```

---

### 11.3 Marquer comme Lu
**`PATCH`** `/notifications/{id}/lire`

### 11.4 Marquer Tout comme Lu
**`PATCH`** `/notifications/lire-tout`

### 11.5 Supprimer Notification
**`DELETE`** `/notifications/{id}`

### 11.6 Notification Globale (Admin)
**`POST`** `/notifications/broadcast`

**Body (JSON):**
```json
{
    "titre": "Fermeture exceptionnelle",
    "message": "L'université sera fermée le 20 janvier 2024 pour maintenance.",
    "type": "Avertissement",
    "lien": null
}
```

**✅ Réponse (200):**
```json
{
    "success": true,
    "message": "Notification envoyée à tous les utilisateurs",
    "data": {"destinataires": 250}
}
```

---

## ⚠️ Codes d'Erreur Globaux

| Code | Description |
|------|-------------|
| `200` | Succès |
| `201` | Créé avec succès |
| `400` | Requête invalide |
| `401` | Non authentifié |
| `403` | Accès interdit |
| `404` | Ressource non trouvée |
| `422` | Erreur de validation |
| `423` | Compte bloqué |
| `500` | Erreur serveur |

---

## 📥 Collection Postman JSON

```json
{
    "info": {
        "name": "ISMGL API",
        "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
    },
    "variable": [
        {"key": "base_url", "value": "http://localhost/ismgl-api/api/v1"},
        {"key": "token", "value": ""},
        {"key": "refresh_token", "value": ""}
    ],
    "auth": {
        "type": "bearer",
        "bearer": [{"key": "token", "value": "{{token}}"}]
    }
}
```
```

---

