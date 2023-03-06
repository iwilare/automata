{-# OPTIONS --without-K --safe #-}

module Categories.Functor.Profunctor.FormalComposite where

open import Level
open import Relation.Binary.Construct.Closure.SymmetricTransitive as ST using (Plus⇔; minimal)
import Relation.Binary.Reasoning.Setoid as SetoidR

open import Relation.Binary.Bundles
open import Categories.Category
open import Categories.Category.Instance.Setoids using (Setoids)
open import Categories.Functor hiding (id)
open import Function.Equality using (Π; _⟨$⟩_; cong)

open Setoid renaming (_≈_ to _[[_≈_]])

module FormalComposite {o ℓ e} {ℓ′ e′ ℓ″ e″}
    (C : Category o ℓ e)
    (F : Functor C (Setoids ℓ′ e′))
    (G : Functor (Category.op C) (Setoids ℓ″ e″)) where
  open Category C
  open Functor F
  module G = Functor G

  record T : Set (o ⊔ ℓ′ ⊔ ℓ″) where
    field
      rendezvous : Obj
      in-side : Setoid.Carrier (F₀ rendezvous)
      out-side : Setoid.Carrier (G.₀ rendezvous)

  record Twines (A B : T) : Set (ℓ ⊔ e′ ⊔ e″) where
    field
      twiner : C [ T.rendezvous A , T.rendezvous B ]
      in-tertwines : F₀ (T.rendezvous B) [[ T.in-side B ≈ F₁ twiner ⟨$⟩ (T.in-side A) ]]
      out-ertwines : G.₀ (T.rendezvous A) [[ T.out-side A ≈ G.₁ twiner ⟨$⟩ (T.out-side B) ]]

  open Twines

  category : Category _ _ _
  category = record
    { Obj = T
    ; _⇒_ = Twines
    ; _≈_ = λ f g → C [ Twines.twiner f ≈ Twines.twiner g ]
    ; id = λ {c} → record
      { twiner = Category.id C
      ; in-tertwines = let x = F₀ (T.rendezvous c) in sym x (identity (refl x))
      ; out-ertwines = let x = G.₀ (T.rendezvous c) in sym x (G.identity (refl x)) }
    ; _∘_ = λ {a b c} f g → record
      { twiner = twiner f ∘ twiner g
      ; in-tertwines = let open SetoidR (F₀ (T.rendezvous c)) in
        begin
          T.in-side c
        ≈⟨ in-tertwines f ⟩
          F₁ (twiner f) ⟨$⟩ T.in-side b
        ≈⟨ F-resp-≈ Equiv.refl (in-tertwines g) ⟩
          F₁ (twiner f) ⟨$⟩ (F₁ (twiner g) ⟨$⟩ T.in-side a)
        ≈⟨ sym (F₀ (T.rendezvous c)) (homomorphism (refl (F₀ (T.rendezvous a)))) ⟩
          F₁ (twiner f ∘ twiner g) ⟨$⟩ T.in-side a
        ∎
      ; out-ertwines = let open SetoidR (G.₀ (T.rendezvous a)) in
        begin
          T.out-side a
        ≈⟨ out-ertwines g ⟩
          G.₁ (twiner g) ⟨$⟩ T.out-side b
        ≈⟨ G.F-resp-≈ Equiv.refl (out-ertwines f) ⟩
          G.₁ (twiner g) ⟨$⟩ (G.₁ (twiner f) ⟨$⟩ T.out-side c)
        ≈⟨ sym (G.₀ (T.rendezvous a)) (G.homomorphism (refl (G.₀ (T.rendezvous c)))) ⟩
          G.₁ (twiner f ∘ twiner g) ⟨$⟩ T.out-side c
        ∎
      }
    ; assoc = assoc
    ; sym-assoc = sym-assoc
    ; identityˡ = identityˡ
    ; identityʳ = identityʳ
    ; identity² = identity²
    ; equiv = record { refl = Equiv.refl ; sym = Equiv.sym ; trans = Equiv.trans }
    ; ∘-resp-≈ = ∘-resp-≈
    }

  setoid = ST.setoid Twines (Category.id category)
