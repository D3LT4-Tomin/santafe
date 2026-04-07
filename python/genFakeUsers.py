import firebase_admin
from faker import Faker
from firebase_admin import auth, credentials, firestore
import argparse
import json
import random
from datetime import datetime, timedelta, timezone
from pathlib import Path
import uuid

cred = credentials.Certificate("./tomin-1-firebase-adminsdk-fbsvc-2475adb493.json")
firebase_admin.initialize_app(cred)

db = firestore.client()
fake = Faker()
REGISTRY_FILE = Path("seeded_users_registry.jsonl")

# Categories
EXPENSE_CATEGORIES = [
    'Comida',
    'Transporte',
    'Suscripción',
    'Salud',
    'Entretenimiento',
    'Servicios',
    'Varios',
]

INCOME_CATEGORIES = [
    'Salario',
    'Freelance',
    'Inversión',
    'Bono',
    'Venta',
    'Otro',
]

FILTER_ORIGINS = [
    'Efectivo',
    'Tarjeta Débito',
    'Tarjeta Crédito',
    'Transferencia',
    'Depósito',
]

ACCOUNT_TYPES = ['bank', 'cash', 'investment']
ACCOUNT_NAMES = ['Cuenta Corriente', 'Ahorros', 'Inversión', 'Efectivo']






# Transaction titles samples
EXPENSE_TITLES = { # 
    'Comida': ['Restaurante', 'Supermercado', 'Café', 'Delivery de comida', 'Panadería'],
    'Transporte': ['Uber', 'Taxi', 'Gasolina', 'Metro', 'Bus'],
    'Suscripción': ['Netflix', 'Spotify', 'Disney+', 'Gym', 'Streaming'],
    'Salud': ['Farmacia', 'Doctor', 'Dentista', 'Hospital', 'Medicina'],
    'Entretenimiento': ['Cine', 'Concierto', 'Bar', 'Videojuegos', 'Evento'],
    'Servicios': ['Internet', 'Electricidad', 'Agua', 'Gas', 'Teléfono'],
    'Varios': ['Ropa', 'Libros', 'Juguetes', 'Accesorios', 'Otros'],
}

INCOME_TITLES = {
    'Salario': ['Salario mensual', 'Salario quincenal'],
    'Freelance': ['Proyecto freelance', 'Trabajo independiente', 'Consultoría'],
    'Inversión': ['Dividendos', 'Intereses', 'Ganancias inversión'],
    'Bono': ['Bono anual', 'Bono proyecto', 'Bono rendimiento'],
    'Venta': ['Venta producto', 'Venta artículo', 'Comisión venta'],
    'Otro': ['Regalo', 'Reembolso', 'Otro ingreso'],
}

# Learning lessons and points (mirrors app catalog)
LESSON_POINTS = {
    'conceptos_base': 50,
    'presupuesto_semanal': 75,
    'a_donde_se_va_tu_dinero': 100,
    'control_gastos': 80,
    'analisis_categorias': 100,
    'tendencias_mensuales': 120,
    'intro_planeacion': 60,
    'planificacion_anual': 150,
    'gastos_hormiga': 100,
    'emergencias_ahorros': 90,
    'finanzas_familiares': 120,
    'metas_corto_plazo': 80,
    'por_que_ahorrar': 50,
    'reducir_gastos': 100,
    'ahorro_basico': 80,
    'ahorrar_comida': 90,
    'inversion_ninos': 180,
    'metodo_50_30_20': 110,
}


def _calculate_seeded_badges(completed_lessons, current_streak):
    badges = []
    completed_count = len(completed_lessons)

    if completed_count >= 1:
        badges.append('first_lesson')
    if completed_count >= 5:
        badges.append('five_lessons')
    if current_streak >= 7:
        badges.append('week_streak')
    if current_streak >= 30:
        badges.append('month_streak')
    if current_streak >= 365:
        badges.append('year_streak')
    if 'ahorro_basico' in completed_lessons:
        badges.append('first_savings')

    return badges


def generate_learning_progress():
    """Generate realistic learning progress for a seeded user."""
    lesson_ids = list(LESSON_POINTS.keys())
    completed_count = random.randint(0, min(8, len(lesson_ids)))
    completed_lessons = random.sample(lesson_ids, completed_count)
    total_points = sum(LESSON_POINTS[lesson_id] for lesson_id in completed_lessons)

    if completed_count == 0:
        current_streak = 0
        total_streak_days = 0
        last_completed_date = None
        last_streak_date = None
        weekdays_completed = []
    else:
        current_streak = random.randint(1, min(10, completed_count + 2))
        total_streak_days = current_streak + random.randint(0, 25)

        days_ago = random.randint(0, 5)
        last_date = datetime.now(timezone.utc) - timedelta(days=days_ago)
        last_completed_date = last_date.isoformat()
        last_streak_date = last_date.isoformat()

        weekday_count = min(7, max(1, current_streak))
        weekdays_completed = sorted(random.sample([1, 2, 3, 4, 5, 6, 7], weekday_count))

    badges = _calculate_seeded_badges(completed_lessons, current_streak)

    return {
        'totalPoints': total_points,
        'currentStreak': current_streak,
        'totalStreakDays': total_streak_days,
        'lastCompletedDate': last_completed_date,
        'lastStreakDate': last_streak_date,
        'completedLessons': completed_lessons,
        'badges': badges,
        'weekdaysCompleted': weekdays_completed,
        'createdAt': firestore.SERVER_TIMESTAMP,
        'updatedAt': firestore.SERVER_TIMESTAMP,
    }


def append_user_registry_file(registry_entry, registry_file=REGISTRY_FILE):
    """Append one seeded user to a local JSONL registry file."""
    with registry_file.open('a', encoding='utf-8') as f:
        f.write(json.dumps(registry_entry, ensure_ascii=False) + "\n")


def create_auth_user(default_password):
    """Create a Firebase Auth user and return uid/email/display_name/password."""
    display_name = fake.name()
    email = fake.unique.email()

    user_record = auth.create_user(
        email=email,
        password=default_password,
        display_name=display_name,
        email_verified=True,
    )

    return {
        'uid': user_record.uid,
        'email': email,
        'displayName': display_name,
        'password': default_password,
    }


def generate_fake_user(default_password):
    """Generate one realistic app user in Auth + Firestore."""
    auth_user = create_auth_user(default_password)
    user_id = auth_user['uid']

    user_data = {
        'email': auth_user['email'],
        'displayName': auth_user['displayName'],
        'totalBalance': 0,
        'createdAt': fake.date_time_this_year(tzinfo=timezone.utc),
    }
    
    # Add user to Firestore
    db.collection('users').document(user_id).set(user_data)

    learning_progress = generate_learning_progress()
    db.collection('users').document(user_id).collection('learning').document('progress').set(
        learning_progress
    )
    
    # Generate 2-4 accounts per user
    num_accounts = random.randint(2, 4)
    total_balance = 0
    total_transactions = 0
    total_expenses = 0
    total_incomes = 0
    account_summaries = []
    
    for _ in range(num_accounts):
        account_id = db.collection('users').document(user_id).collection('accounts').document().id
        account_type = random.choice(ACCOUNT_TYPES)
        account_balance = round(random.uniform(100, 10000), 2)
        total_balance += account_balance
        
        account_data = {
            'name': random.choice(ACCOUNT_NAMES),
            'accountNumber': fake.credit_card_number() if account_type == 'bank' else None,
            'balance': account_balance,
            'type': account_type,
            'logoUrl': None,
            'createdAt': fake.date_time_this_year(tzinfo=timezone.utc),
            'returnRate': round(random.uniform(0, 12), 2) if account_type == 'investment' else None,
        }
        
        db.collection('users').document(user_id).collection('accounts').document(account_id).set(account_data)
        
        # Generate 10-30 transactions per account
        num_transactions = random.randint(10, 30)
        account_expenses = 0
        account_incomes = 0
        for _ in range(num_transactions):
            # Mix expenses and income (80% expenses, 20% income)
            is_expense = random.random() < 0.8
            
            if is_expense:
                category = random.choice(EXPENSE_CATEGORIES)
                title = random.choice(EXPENSE_TITLES[category])
                amount = -round(random.uniform(5, 500), 2)
                tipo = 'egreso'
                account_expenses += 1
            else:
                category = random.choice(INCOME_CATEGORIES)
                title = random.choice(INCOME_TITLES[category])
                amount = round(random.uniform(100, 5000), 2)
                tipo = 'ingreso'
                account_incomes += 1
            
            transaction_created_at = fake.date_time_this_year(tzinfo=timezone.utc)
            
            transaction_data = {
                'title': title,
                'subtitle': f"{category} . {transaction_created_at.strftime('%d/%m/%Y')}",
                'amount': amount,
                'category': category,
                'origin': random.choice(FILTER_ORIGINS),
                'tipo': tipo,
                'createdAt': transaction_created_at,
                'accountId': account_id,
                'accountName': account_data['name'],
            }
            
            db.collection('users').document(user_id).collection('transactions').document().set(transaction_data)

        total_transactions += num_transactions
        total_expenses += account_expenses
        total_incomes += account_incomes
        account_summaries.append({
            'accountId': account_id,
            'name': account_data['name'],
            'type': account_type,
            'balance': account_balance,
            'transactions': num_transactions,
            'expenses': account_expenses,
            'incomes': account_incomes,
        })
    
    # Update total balance
    db.collection('users').document(user_id).update({'totalBalance': total_balance})

    return {
        'userId': user_id,
        'email': user_data['email'],
        'displayName': user_data['displayName'],
        'password': auth_user['password'],
        'totalBalance': round(total_balance, 2),
        'accountsCount': num_accounts,
        'transactionsCount': total_transactions,
        'expensesCount': total_expenses,
        'incomesCount': total_incomes,
        'learningPoints': learning_progress['totalPoints'],
        'completedLessonsCount': len(learning_progress['completedLessons']),
        'badgesCount': len(learning_progress['badges']),
        'accounts': account_summaries,
    }


def insert_fake_users(num_users, default_password):
    """Insert multiple fake users into Firebase Auth + Firestore."""
    seed_run_id = str(uuid.uuid4())

    print(f"Generating {num_users} fake users in Auth + Firestore...")
    print(f"Seed run ID: {seed_run_id}")
    
    for i in range(num_users):
        summary = generate_fake_user(default_password)
        registry_entry = {
            'seedRunId': seed_run_id,
            'uid': summary['userId'],
            'email': summary['email'],
            'displayName': summary['displayName'],
            'password': summary['password'],
            'firestoreUserPath': f"users/{summary['userId']}",
            'accountsCount': summary['accountsCount'],
            'transactionsCount': summary['transactionsCount'],
            'learningPoints': summary['learningPoints'],
            'completedLessonsCount': summary['completedLessonsCount'],
            'badgesCount': summary['badgesCount'],
            'createdAt': datetime.now(timezone.utc).isoformat(),
        }
        append_user_registry_file(registry_entry)

    
    print(f"\nSuccessfully inserted {num_users} users into Auth + Firestore!")
    print(f"Local registry file: {REGISTRY_FILE.resolve()}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Seed realistic Firebase users')
    parser.add_argument('--num-users', type=int, default=2)
    parser.add_argument('--password', type=str, default='123qwe')
    args = parser.parse_args()

    insert_fake_users(num_users=args.num_users, default_password=args.password)


