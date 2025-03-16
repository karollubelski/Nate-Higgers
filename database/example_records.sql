INSERT INTO public.adresy (adres_id, miejscowosc, ulica, numer_domu, kod_pocztowy)
VALUES 
  (1, 'Warszawa', 'Marszałkowska', '45A', 00001),
  (2, 'Olsztyn', 'Słoneczna', '54', 10710),
  (3, 'Gdańsk', 'Długa', '23', 80001),
  (4, 'Poznań', 'Stary Rynek', '5', 60001),
  (5, 'Wrocław', 'Świdnicka', '18', 50001);
  
INSERT INTO public.rejestracja (id_rejestracji, login, haslo)
VALUES 
  (1, 'jan_kowalski', 'haslo123'),
  (2, 'anna_nowak', 'qwerty456'),
  (3, 'piotr_wisniewski', 'bezpieczne789'),
  (4, 'pawel_jumper', 'lolo123!'),
  (5, 'marta_nic', 'aaaa2023');

INSERT INTO public.klienci (id_rejestracji, id_klienta, imie, nazwisko, numer_telefonu, email, prawo_jazdy, data_urodzenia, adres_id)
VALUES 
  (1, 1, 'Jan', 'Kowalski', '123456789012', 'jan.kowalski@email.pl', 'ABC123456', '1985-04-15', 1),
  (2, 2, 'Anna', 'Nowak', '234567890123', 'anna.nowak@email.pl', 'DEF789012', '1990-07-22', 2),
  (3, 3, 'Piotr', 'Wiśniewski', '345678901234', 'piotr.wisniewski@email.pl', 'GHI345678', '1982-11-03', 3);
  
INSERT INTO public.pracownicy (id_rejestracji, id_pracownika, imie, nazwisko, numer_telefonu, email, prawo_jazdy, data_urodzenia, adres_id)
VALUES 
  (4, 1, 'Paweł', 'Jumper', '789012345678', 'pawel.jumper@firma.pl', 'STU890123', '1980-05-14', 4),
  (5, 2, 'Marta', 'Nicniewarta', '890123456789', 'marta.nic@firma.pl', 'VWX456789', '1992-08-25', 5);

INSERT INTO public.koszt (koszt_id, koszt_rodzaj_samochodu, koszt_dzien, koszt_kilometr)
VALUES 
  (1, 'Ekonomiczny', 100.00, 0.50),
  (2, 'Kompakt', 150.00, 0.60),
  (3, 'SUV', 200.00, 0.75),
  (4, 'Premium', 300.00, 1.00),
  (5, 'Van', 250.00, 0.80),
  (6, 'Sportowy', 500.00, 1.50);

INSERT INTO public.samochody (samochod_id, koszt_id, marka, model, typ_samochodu, ilosc_miejsc, dostepnosc)
VALUES 
  (1, 1, 'Toyota', 'Yaris', 'Ekonomiczny', 5, TRUE),
  (2, 2, 'Volkswagen', 'Golf', 'Kompakt', 5, TRUE),
  (3, 3, 'Nissan', 'Qashqai', 'SUV', 5, TRUE),
  (4, 4, 'BMW', 'Seria 5', 'Premium', 5, TRUE),
  (5, 5, 'Volkswagen', 'Transporter', 'Van', 9, TRUE),
  (6, 6, 'Porsche', '911', 'Sportowy', 2, TRUE);

INSERT INTO public.platnosc (platnosc_id, id_potwierdzenia, metoda_platnosci, kwota)
VALUES 
  (1, 1001, 'Karta kredytowa', 450.00),
  (2, 1002, 'Przelew bankowy', 750.00),
  (3, 1003, 'Gotówka', 600.00),
  (4, 1004, 'Karta kredytowa', 1200.00),
  (5, 1005, 'BLIK', 500.00);

INSERT INTO public.wypozyczenia (wypozyczenie_id, id_klienta, platnosc_id, samochod_id, id_pracownika, start_wypozyczenia, koniec_wypozyczenia, przebieg_start, przebieg_koniec)
VALUES 
  (1, 1, 1, 1, 1, '2025-03-01', '2025-03-05', 45000, 45350),
  (2, 2, 2, 3, 2, '2025-03-10', '2025-03-15', 28500, 29100);